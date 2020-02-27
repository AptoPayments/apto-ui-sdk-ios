//
//  ShiftCardModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/18/2018.
//
//

import Foundation
import AptoSDK

@objc public enum ShiftCardModuleMode: Int {
  case standalone
  case embedded
}

open class ShiftCardModule: UIModule {
  let mode: ShiftCardModuleMode
  let options: CardOptions?
  var welcomeScreenModule: ShowGenericMessageModule?
  var authModule: AuthModuleProtocol?
  var existingShiftCardModule: UIModuleProtocol?
  var newShiftCardModule: NewShiftCardModule?

  var contextConfiguration: ContextConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  var projectConfiguration: ProjectConfiguration {
    return contextConfiguration.projectConfiguration
  }
  var userDataPoints: DataPointList

  public init(mode: ShiftCardModuleMode, initialUserData: DataPointList? = nil, options: CardOptions? = nil) {
    if let initialUserData = initialUserData {
      self.userDataPoints = initialUserData.copy() as! DataPointList // swiftlint:disable:this force_cast
    }
    else {
      self.userDataPoints = DataPointList()
    }
    self.mode = mode
    self.options = options
    super.init(serviceLocator: ServiceLocator.shared)
  }

  // MARK: - Module Initialization
  override public func close() {
    serviceLocator.notificationHandler.removeObserver(self, name: .UserTokenSessionExpiredNotification)
    serviceLocator.notificationHandler.removeObserver(self, name: .UserTokenSessionClosedNotification)
    serviceLocator.notificationHandler.removeObserver(self, name: .UserTokenSessionInvalidNotification)
    serviceLocator.notificationHandler.removeObserver(self, name: UIApplication.willEnterForegroundNotification)
    super.close()
  }

  override public func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    // Store the passed-in options in the storage
    if let options = self.options {
      platform.setCardOptions(options)
    }
    self.loadConfigurationFromServer { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
        return
      case .success:
        self.serviceLocator.notificationHandler.addObserver(self,
                                                            selector: #selector(self.didReceiveSessionExpiredEvent(_:)),
                                                            name: .UserTokenSessionExpiredNotification)
        self.serviceLocator.notificationHandler.addObserver(self,
                                                            selector: #selector(self.didReceiveSessionClosedEvent(_:)),
                                                            name: .UserTokenSessionClosedNotification)
        self.serviceLocator.notificationHandler.addObserver(self,
                                                            selector: #selector(self.didReceiveSessionClosedEvent(_:)),
                                                            name: .UserTokenSessionInvalidNotification)
        // Prepare the initial screen
        self.prepareInitialScreen(completion)
      }
    }
  }

  fileprivate func prepareInitialScreen(_ completion:@escaping Result<UIViewController, NSError>.Callback) {
    if self.projectConfiguration.welcomeScreenAction.status == .enabled {
      let welcomeScreenModule = self.buildWelcomeScreenModule()
      self.addChild(module: welcomeScreenModule, completion: completion)
    }
    else {
      guard self.platform.currentToken() != nil else {
        // There's no user. Show the auth module
        self.showAuthModule(addChild: true, completion: completion)
        return
      }
      // There's a user. Check if he has already cards.
      self.showExistingOrNewCardModule(addChild: true, completion: completion)
    }
  }

  // MARK: - Welcome Screen Module Handling

  fileprivate func buildWelcomeScreenModule() -> ShowGenericMessageModule {
    let welcomeScreenModule = ShowGenericMessageModule(
      serviceLocator: serviceLocator,
      showGenericMessageAction: projectConfiguration.welcomeScreenAction)
    welcomeScreenModule.onWelcomeScreenContinue = { [weak self] module in
      guard let self = self else { return }
      guard self.platform.currentToken() != nil else {
        // There's no user. Show the auth module
        self.showAuthModule { _ in }
        return
      }
      // There's a user. Check if he has already cards.
      self.showExistingOrNewCardModule { _ in }
    }
    welcomeScreenModule.onClose = { [weak self] module in
      self?.close()
    }
    return welcomeScreenModule
  }

  // MARK: - Auth Module Handling

  fileprivate func showAuthModule(addChild: Bool = false,
                                  completion: @escaping Result<UIViewController, NSError>.Callback) {
    // Prepare the current user's data
    let authModuleConfig = AuthModuleConfig(projectConfiguration: projectConfiguration)
    let authModule = serviceLocator.moduleLocator.authModule(authConfig: authModuleConfig,
                                                             initialUserData: userDataPoints)
    authModule.onExistingUser = { [weak self] module, user in
      guard let wself = self else {
        return
      }
      wself.userDataPoints = user.userData.copy() as! DataPointList // swiftlint:disable:this force_cast
      // There's a user. Check if he has already cards.
      wself.showExistingOrNewCardModule { _ in
        wself.authModule = nil
      }
    }
    self.authModule = authModule
    if addChild {
      authModule.onClose = { [unowned self] module in
        self.authModule = nil
        self.close()
      }
      self.addChild(module: authModule, leftButtonMode: .close, completion: completion)
    }
    else {
      authModule.onClose = { [unowned self] module in
      self.popModule {
        self.authModule = nil
      }
    }
      self.push(module: authModule, leftButtonMode: .close, completion: completion)
    }
  }

  // MARK: - Existing or new Card Flows

  fileprivate func showExistingOrNewCardModule(addChild: Bool = false, pushModule: Bool = false,
                                               completion: @escaping Result<UIViewController, NSError>.Callback) {
    showLoadingView()
    platform.fetchCards(page: 0, rows: 100) { [unowned self] result in
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let cards):
        let nonClosedCards = cards.filter { $0.state != .cancelled }
        if let card = nonClosedCards.first {
          self.showManageCardModule(card: card, addChild: addChild, pushModule: pushModule, completion: completion)
        }
        else {
          self.showCardProductSelector(addChild: addChild, completion: completion)
        }
      }
    }
  }

  @objc private func appDidBecomeActive() {
    let authenticationManager = serviceLocator.systemServicesLocator.authenticationManager()
    if authenticationManager.shouldAuthenticateOnStartUp() {
      authenticationManager.authenticate(from: self) { _ in }
    }
  }

  private func handleAuthentication(completion: @escaping () -> Void) {
    let authenticationManager = serviceLocator.systemServicesLocator.authenticationManager()
    if authenticationManager.shouldAuthenticateOnStartUp() {
      serviceLocator.notificationHandler.addObserver(self, selector: #selector(appDidBecomeActive),
                                                     name: UIApplication.willEnterForegroundNotification)
      authenticationManager.authenticate(from: self) { accessGranted in
        if accessGranted {
          completion()
        }
      }
    }
    else if authenticationManager.shouldCreateCode() {
      serviceLocator.notificationHandler.addObserver(self, selector: #selector(appDidBecomeActive),
                                                     name: UIApplication.willEnterForegroundNotification)
      let module = serviceLocator.moduleLocator.createPasscodeModule()
      module.onFinish = { [unowned self] _ in
        self.showBiometricPermission(from: module) {
          self.dismissModule {
            completion()
          }
        }
      }
      present(module: module) { _ in }
    }
    else {
      completion()
    }
  }

  private func showBiometricPermission(from parent: UIModuleProtocol, completion: @escaping () -> Void) {
    let authenticationManager = serviceLocator.systemServicesLocator.authenticationManager()
    guard authenticationManager.shouldRequestBiometricPermission else {
      completion()
      return
    }
    let module = serviceLocator.moduleLocator.biometricPermissionModule()
    module.onFinish = { _ in
      completion()
    }
    module.onClose = { _ in
      completion()
    }
    parent.push(module: module) { _ in }
  }

  private func showManageCardModule(card: Card, addChild: Bool, pushModule: Bool,
                                    completion: @escaping Result<UIViewController, NSError>.Callback) {
    self.handleAuthentication { [unowned self] in
      let existingCardModule = self.serviceLocator.moduleLocator.manageCardModule(card: card, mode: self.mode)
      self.existingShiftCardModule = existingCardModule
      let leftButtonMode: UIViewControllerLeftButtonMode = self.mode == .standalone ? .none : .close
      if addChild {
        existingCardModule.onClose = { [unowned self] _ in
          self.close()
        }
        self.addChild(module: existingCardModule, leftButtonMode: leftButtonMode, completion: completion)
      }
      else {
        if pushModule {
          existingCardModule.onClose = { [unowned self] _ in
            self.popModule(animated: false) { [unowned self] in
              self.close()
            }
          }
          self.push(module: existingCardModule, animated: true, leftButtonMode: leftButtonMode, completion: completion)
        }
        else {
          existingCardModule.onClose = { [unowned self] _ in
            self.close()
          }
          self.present(module: existingCardModule, leftButtonMode: leftButtonMode, completion: completion)
        }
      }
    }
  }

  private func showCardProductSelector(addChild: Bool,
                                       completion: @escaping Result<UIViewController, NSError>.Callback) {
    let module = serviceLocator.moduleLocator.cardProductSelectorModule()
    module.onCardProductSelected = { [unowned self] cardProduct in
      // The product selector might call the callback before presenting the UI in which case we need to add the module
      // as the base child module
      if self.navigationController == nil {
        self.showNewCardModule(addChild: true, cardProductId: cardProduct.id, completion: completion)
      }
      else {
        self.showNewCardModule(addChild: false, cardProductId: cardProduct.id) { _ in }
      }
    }
    if addChild {
      module.onClose = { [unowned self] _ in
        self.close()
      }
      self.addChild(module: module, completion: completion)
    }
    else {
      module.onClose = { [unowned self] _ in
        self.popModule {}
      }
      push(module: module, completion: completion)
    }
  }

  private func showNewCardModule(addChild: Bool, cardProductId: String,
                                 completion: @escaping Result<UIViewController, NSError>.Callback) {
    let newShiftCardModule = NewShiftCardModule(serviceLocator: serviceLocator, initialDataPoints: userDataPoints,
                                                cardProductId: cardProductId)
    self.newShiftCardModule = newShiftCardModule
    if addChild {
      newShiftCardModule.onClose = { [unowned self] _ in
        self.close()
      }
      newShiftCardModule.onFinish = { [unowned self] module in
        self.showExistingOrNewCardModule { [unowned self] _ in
          self.remove(module: module) { [unowned self] in
            self.newShiftCardModule = nil
          }
        }
      }
      self.addChild(module: newShiftCardModule, completion: completion)
    }
    else {
      newShiftCardModule.onClose = { [unowned self] _ in
        self.popModule {}
      }
      newShiftCardModule.onFinish = { module in
        self.showExistingOrNewCardModule(addChild: false, pushModule: true) { [unowned self] result in
          self.newShiftCardModule = nil
          completion(result)
        }
      }
      push(module: newShiftCardModule, replacePrevious: true, completion: completion)
    }
  }

  // MARK: - Configuration HandlingApplication

  fileprivate func loadConfigurationFromServer(_ completion:@escaping Result<Void, NSError>.Callback) {
    platform.fetchContextConfiguration { [unowned self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success (let contextConfiguration):
        self.contextConfiguration = contextConfiguration
        completion(.success(Void()))
      }
    }
  }

  // MARK: - Notification Handling

  @objc private func didReceiveSessionExpiredEvent(_ notification: Notification) {
    DispatchQueue.main.async { [unowned self] in
      self.hideLoadingView()
      self.hideLoadingSpinner()
      self.clearUserToken()
      UIAlertController.confirm(title: "error.transport.sessionExpired.title".podLocalized(),
                                message: "error.transport.sessionExpired".podLocalized(),
                                okTitle: "general.button.ok".podLocalized()) { [weak self] _ in
                                  self?.close()
      }
    }
  }

  @objc private func didReceiveSessionClosedEvent(_ notification: Notification) {
    self.hideLoadingView()
    self.hideLoadingSpinner()
    clearUserToken()
    close()
  }

  fileprivate func clearUserToken() {
    serviceLocator.systemServicesLocator.authenticationManager().invalidateCurrentCode()
    FileDownloaderImpl.clearCache()
    AptoPlatform.defaultManager().clearUserToken()
    serviceLocator.notificationHandler.removeObserver(self, name: UIApplication.willEnterForegroundNotification)
  }
}
