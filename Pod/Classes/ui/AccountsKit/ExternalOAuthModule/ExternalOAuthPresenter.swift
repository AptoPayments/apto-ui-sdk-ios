//
//  ExternalOAuthPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import AptoSDK
import Foundation

class ExternalOAuthPresenter: ExternalOAuthPresenterProtocol {
    let config: ExternalOAuthModuleConfig
    // swiftlint:disable implicitly_unwrapped_optional
    var interactor: ExternalOAuthInteractorProtocol!
    weak var router: ExternalOAuthRouterProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    let viewModel = ExternalOAuthViewModel()
    var analyticsManager: AnalyticsServiceProtocol?
    private var custodianType: String?

    init(config: ExternalOAuthModuleConfig) {
        self.config = config
    }

    func viewLoaded() {
        viewModel.title.send(config.title)
        viewModel.explanation.send(config.explanation)
        viewModel.callToAction.send(config.callToAction)
        viewModel.newUserAction.send(config.newUserAction)
        viewModel.allowedBalanceTypes.send(config.allowedBalanceTypes)
        viewModel.assetUrl.send(config.assetUrl)
        analyticsManager?.track(event: Event.selectBalanceStoreLogin)
    }

    func balanceTypeTapped(_ balanceType: AllowedBalanceType) {
        router.showLoadingView()
        custodianType = balanceType.type
        interactor.balanceTypeSelected(balanceType)
        analyticsManager?.track(event: Event.selectBalanceStoreLoginConnectTap)
    }

    func closeTapped() {
        router.backInExternalOAuth(true)
    }

    func show(error: NSError) {
        viewModel.error.send(error)
    }

    func show(url: URL) {
        router.hideLoadingView()
        router.show(url: url) { [weak self] in
            self?.router.showLoadingView()
            self?.interactor.verifyOauthAttemptStatus { [weak self] result in
                self?.router.hideLoadingView()
                guard let self = self else { return }
                self.handleOauthAttemptVerificationResult(result: result)
            }
        }
    }

    func newUserTapped(url: URL) {
        router.show(url: url) {}
    }

    private func handleOauthAttemptVerificationResult(result: Result<OauthAttempt, NSError>) {
        guard let custodianType = custodianType else { return }
        switch result {
        case let .failure(error):
            show(error: error)
        case let .success(attempt):
            switch attempt.status {
            case .passed:
                guard let credentials = attempt.credentials else { return }
                let custodian = Custodian(custodianType: custodianType, name: custodianType)
                custodian.externalCredentials = .oauth(credentials)
                router.oauthSucceeded(custodian)
            case .failed:
                let errorMessage = attempt.errorMessage(errorMessageKeys: config.oauthErrorMessageKeys)
                let userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorMessage ?? ""]
                let error = NSError(domain: "com.aptopayments.error", code: 1, userInfo: userInfo)
                show(error: error)
            case .pending:
                // Nothing to do here
                break
            }
        }
    }
}

extension OauthAttempt {
    private var defaultErrorMessageKeys: [String] { return [
        "select_balance_store.login.error_oauth_invalid_request.message",
        "select_balance_store.login.error_oauth_unauthorised_client.message",
        "select_balance_store.login.error_oauth_access_denied.message",
        "select_balance_store.login.error_oauth_unsupported_response_type.message",
        "select_balance_store.login.error_oauth_invalid_scope.message",
        "select_balance_store.login.error_oauth_server_error.message",
        "select_balance_store.login.error_oauth_temporarily_unavailable.message",
    ]
    }

    func errorMessage(errorMessageKeys: [String]? = nil) -> String? {
        guard let error = error else { return nil }
        let errorKeys = (errorMessageKeys ?? []) + defaultErrorMessageKeys
        var errorKey = errorKeys.first { $0.endsWith("\(error).message") }
        if errorKey == nil {
            errorKey = errorKeys.first { $0.endsWith("\(error).unknown.message") }
        }
        return errorKey?.podLocalized().replace(["<<ERROR_MESSAGE>>": errorMessage ?? ""])
    }
}
