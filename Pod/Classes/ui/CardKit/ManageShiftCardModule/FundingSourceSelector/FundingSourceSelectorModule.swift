//
// FundingSourceSelectorModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import Foundation
import AptoSDK

class FundingSourceSelectorModule: UIModule, FundingSourceSelectorModuleProtocol {
  private let card: Card
  private var presenter: FundingSourceSelectorPresenterProtocol?
  private var externalOAuthModule: ExternalOAuthModule?

  init(serviceLocator: ServiceLocatorProtocol, card: Card) {
    self.card = card
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    completion(.success(buildViewController()))
  }

  func fundingSourceChanged() {
    self.onFinish?(self)
  }

  func addFundingSource(completion: @escaping (FundingSource) -> Void) {
    guard let allowedBalanceTypes = card.features?.allowedBalanceTypes, !allowedBalanceTypes.isEmpty else {
      return
    }
    let title = "external_auth.login.title".podLocalized()
    let explanation = "external_auth.login.explanation".podLocalized()
    let callToAction = "external_auth.login.call_to_action.title".podLocalized()
    let newUserAction = "external_auth.login.new_user.title".podLocalized()
    let oauthModuleConfig = ExternalOAuthModuleConfig(title: title, explanation: explanation,
                                                      callToAction: callToAction, newUserAction: newUserAction,
                                                      allowedBalanceTypes: allowedBalanceTypes,
                                                      oauthErrorMessageKeys: oauthErrorMessageKeys)
    let externalOAuthModule = ExternalOAuthModule(serviceLocator: serviceLocator,
                                                  config: oauthModuleConfig,
                                                  uiConfig: uiConfig)
    externalOAuthModule.onOAuthSucceeded = { [weak self] _, custodian in
      guard let self = self else { return }
      self.showLoadingSpinner()
      self.platform.addCardFundingSource(cardId: self.card.accountId, custodian: custodian) { [weak self] result in
        self?.hideLoadingSpinner()
        switch result {
        case .failure(let error):
          self?.handle(error: error)
        case .success(let fundingSource):
          self?.dismissModule {
            self?.externalOAuthModule = nil
            completion(fundingSource)
          }
        }
      }
    }
    externalOAuthModule.onClose = { module in
      self.dismissModule {
        self.externalOAuthModule = nil
      }
    }
    self.externalOAuthModule = externalOAuthModule
    present(module: externalOAuthModule) { _ in }
  }

  // MARK: - Private methods
  private func buildViewController() -> ShiftViewController {
    let presenterConfig = FundingSourceSelectorPresenterConfig(
      hideFundingSourcesReconnectButton: platform.isFeatureEnabled(.hideFundingSourcesReconnectButton)
    )
    let presenter = serviceLocator.presenterLocator.fundingSourceSelectorPresenter(config: presenterConfig)
    let interactor = serviceLocator.interactorLocator.fundingSourceSelector(card: card)
    let viewController = serviceLocator.viewLocator.fundingSourceSelectorView(presenter: presenter)
    navigationController?.modalPresentationStyle = .overCurrentContext
    viewController.modalPresentationStyle = .overCurrentContext
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }

  private func handle(error: NSError) {
    guard let backendError = error as? BackendError, let errorCode = backendError.rawCode else {
      show(error: error)
      return
    }
    let result = SelectBalanceStoreResult(result: .invalid, errorCode: errorCode, errorMessageKeys: errorMessageKeys)
    show(message: result.errorMessage, title: "", isError: true)
  }

  private lazy var errorMessageKeys = [
    "external_auth.login.error_wrong_country.message", 
    "external_auth.login.error_wrong_region.message",
    "external_auth.login.error_unverified_address.message", 
    "external_auth.login.error_unsupported_currency.message",
    "external_auth.login.error_cant_capture_funds.message",
    "external_auth.login.error_insufficient_funds.message",
    "external_auth.login.error_balance_not_found.message",
    "external_auth.login.error_access_token_invalid.message",
    "external_auth.login.error_scopes_required.message",
    "external_auth.login.error_missing_legal_name.message",
    "external_auth.login.error_missing_birthdate.message",
    "external_auth.login.error_wrong_birthdate.message",
    "external_auth.login.error_missing_address.message",
    "external_auth.login.error_missing_email.message",
    "external_auth.login.error_wrong_email.message",
    "external_auth.login.error_email_sends_disabled.message",
    "external_auth.login.error_insufficient_application_limit.message",
    "external_auth.login.error_identity_not_verified.message",
    "external_auth.login.error_unknown.message"
  ]

  private var oauthErrorMessageKeys: [String] { return [
    "external_auth.login.error_oauth_invalid_request.message",
    "external_auth.login.error_oauth_unauthorised_client.message",
    "external_auth.login.error_oauth_access_denied.message",
    "external_auth.login.error_oauth_unsupported_response_type.message",
    "external_auth.login.error_oauth_invalid_scope.message",
    "external_auth.login.error_oauth_server_error.message",
    "external_auth.login.error_oauth_temporarily_unavailable.message"
    ]
  }
}
