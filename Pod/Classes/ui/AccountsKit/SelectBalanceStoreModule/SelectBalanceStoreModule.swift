//
//  SelectBalanceStoreModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/06/2018.
//
//

import AptoSDK

protocol SelectBalanceStoreModuleProtocol: UIModuleProtocol {
}

class SelectBalanceStoreModule: UIModule, SelectBalanceStoreModuleProtocol {
  private let externalOAuthModuleConfig: ExternalOAuthModuleConfig
  private let application: CardApplication
  private var dataConfirmationModule: DataConfirmationModuleProtocol?
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var custodian: Custodian?
  private var userData: DataPointList?
  private var analyticsManager: AnalyticsServiceProtocol?

  init(serviceLocator: ServiceLocatorProtocol, application: CardApplication, analyticsManager: AnalyticsServiceProtocol?) {
    self.application = application
    self.analyticsManager = analyticsManager
    guard let action = application.nextAction.configuration as? SelectBalanceStoreActionConfiguration else {
      fatalError("Wrong select balance store configuration")
    }
    externalOAuthModuleConfig = ExternalOAuthModuleConfig(title: "select_balance_store.login.title".podLocalized(),
                                                          allowedBalanceTypes: action.allowedBalanceTypes)
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    platform.fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure (let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.projectConfiguration = contextConfiguration.projectConfiguration
        let module = self.buildExternalOAuthModule(uiConfig: self.uiConfig)
        self.addChild(module: module, completion: completion)
      }
    }
  }

  private func buildExternalOAuthModule(uiConfig: UIConfig) -> UIModuleProtocol {
    let externalOAuthModule = serviceLocator.moduleLocator.externalOAuthModule(config: externalOAuthModuleConfig,
                                                                               uiConfig: uiConfig)
    externalOAuthModule.onClose = { [unowned self] _ in
      self.close()
    }
    externalOAuthModule.onOAuthSucceeded = { [unowned self] _, custodian in
      self.custodian = custodian
      self.showDataConfirmationIfNeededAndConfirm()
    }

    return externalOAuthModule
  }

  private func showDataConfirmationIfNeededAndConfirm() {
    guard let credentials = custodian?.externalCredentials,
          case let .oauth(oauthCredentials) = credentials,
          let userData = oauthCredentials.userData else {
      // If no data to confirm we just succeed
      saveBalanceStore()
      return
    }
    self.userData = userData
    let module = serviceLocator.moduleLocator.dataConfirmationModule(userData: userData)
    module.onClose = { [unowned self] _ in
      self.popModule {
        self.dataConfirmationModule = nil
      }
    }
    module.onFinish = { [unowned self] _ in
      let formatterFactory = DataPointFormatterFactory()
      if let address = self.userData?.getDataPointsOf(type: .address)?.first,
         let formattedAddress = formatterFactory.formatter(for: address).titleValues.first?.value{
        self.confirm(address: formattedAddress)
      }
      else {
        self.uploadUserData()
      }
    }
    module.delegate = self
    self.dataConfirmationModule = module
    push(module: module) { _ in }
  }

  private func confirm(address: String) {
    var message = "select_balance_store.oauth_confirm.address.confirmation_start".podLocalized()
    let separator = "\n\n"
    message += separator + address + separator
    message += "select_balance_store.oauth_confirm.address.confirmation_end".podLocalized()
    let okTitle = "select_balance_store.oauth_confirm.address.ok_button".podLocalized()
    let cancelTitle = "select_balance_store.oauth_confirm.address.cancel_button".podLocalized()
    UIAlertController.confirm(message: message,
                              okTitle: okTitle,
                              cancelTitle: cancelTitle) { [unowned self] action in
      if action.title == okTitle {
        self.uploadUserData()
      }
    }
  }

  private func uploadUserData() {
    guard let userData = self.userData, let custodian = self.custodian else { return }
    showLoadingView()
    userData.removeDataPointsOf(type: projectConfiguration.primaryAuthCredential)
    platform.saveOauthUserData(userData, custodian: custodian) { [weak self] result in
      guard let self = self else { return }
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        self.handleError(error: error)
      case .success(let saveResult):
        self.process(saveOauthResult: saveResult)
      }
    }
  }

  private func process(saveOauthResult result: OAuthSaveUserDataResult) {
    if result.isSuccess {
      saveBalanceStore()
      return
    }
    let errorTitle = "select_balance_store.oauth_confirm.updated_pii_message.title".podLocalized()
    let errorMessage = "select_balance_store.oauth_confirm.updated_pii_message.message".podLocalized()
    let buttonTitle = "select_balance_store.oauth_confirm.updated_pii_message.ok_button".podLocalized()
    let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
    present(viewController: alert, animated: true) {}
    if let userData = result.userData {
      self.userData = userData
      dataConfirmationModule?.updateUserData(userData)
    }
  }

  private func saveBalanceStore() {
    guard let custodian = self.custodian else { return }
    showLoadingView()
    platform.setBalanceStore(applicationId: application.id, custodian: custodian) { [weak self] result in
      self?.hideLoadingView()
      switch result {
      case .failure(let error):
        self?.handleError(error: error)
      case .success(let balanceStoreResult):
        self?.process(result: balanceStoreResult)
      }
    }
  }

  private func process(result: SelectBalanceStoreResult) {
    if result.isSuccess {
      self.onFinish?(self)
    }
    else {
      analyticsManager?.track(event: result.event)
      let alert = UIAlertController(title: "select_balance_store.login.error.title".podLocalized(),
                                    message: result.errorMessage, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "select_balance_store.login.error.ok_button".podLocalized(),
                                    style: .default))
      present(viewController: alert, animated: true) { }
    }
  }

  private func handleError(error: NSError, generalHandler:((NSError) -> Void)? = nil) {
    if let backendError = error as? BackendError, backendError.isOauthTokenRevokedError {
      // Pop data confirmation module and ask the user to login again
      popModule { [unowned self] in
        let errorTitle = "select_balance_store.login.error.title".podLocalized()
        let errorMessage = backendError.localizedDescription
        let buttonTitle = "select_balance_store.login.error.ok_button".podLocalized()
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        self.present(viewController: alert, animated: true) {}
      }
    }
    else if let handler = generalHandler {
      handler(error)
    }
    else {
      self.show(error: error)
    }
  }
}

extension SelectBalanceStoreModule: DataConfirmationModuleDelegate {
  func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback) {
    guard let custodian = self.custodian else { return }
    showLoadingView()
    platform.fetchOAuthData(custodian) { [weak self] result in
      guard let self = self else { return }
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        self.handleError(error: error) { error in
          callback(.failure(error))
        }
      case .success(let oauthUserData):
        guard let dataPointList = oauthUserData.userData else {
          return callback(.failure(BackendError(code: .other)))
        }
        self.userData = dataPointList
        callback(.success(dataPointList))
      }
    }
  }
}
