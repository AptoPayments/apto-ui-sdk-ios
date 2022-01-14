//
//  ShowAgreementModule.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 4/2/21.
//

import AptoSDK
import Foundation

class ShowAgreementModule: UIModule {
    private let cardId: String
    private let disclaimer: Content
    private let actionConfirmer: ActionConfirmer.Type
    private let analyticsManager: AnalyticsServiceProtocol?
    var onDeclineAgreements: (() -> Void)?

    enum AgreementError: Error {
        case noKeysAvailables
        case balanceIdNotFound
    }

    init(serviceLocator: ServiceLocatorProtocol,
         cardId: String,
         disclaimer: Content,
         actionConfirmer: ActionConfirmer.Type,
         analyticsManager: AnalyticsServiceProtocol?)
    {
        self.cardId = cardId
        self.disclaimer = disclaimer
        self.actionConfirmer = actionConfirmer
        self.analyticsManager = analyticsManager
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping (Result<UIViewController, NSError>) -> Void) {
        let module = buildFullScreenDisclaimerModule()
        addChild(module: module, completion: completion)
    }

    // MARK: Private methods

    private func buildFullScreenDisclaimerModule() -> FullScreenDisclaimerModuleProtocol {
        let module = serviceLocator
            .moduleLocator
            .fullScreenDisclaimerModule(disclaimer: disclaimer,
                                        disclaimerTitle: "load_funds.direct_deposit.disclaimer.title",
                                        callToActionTitle: "load_funds.direct_deposit.disclaimer.call_to_action.title",
                                        cancelActionTitle: "load_funds.direct_deposit.disclaimer.cancel_action.title")
        module.onDisclaimerAgreed = disclaimerAgreed
        module.onClose = { [weak self] _ in
            self?.confirmClose { [weak self] in
                self?.onDeclineAgreements?()
            }
        }
        return module
    }

    private func disclaimerAgreed(module _: UIModuleProtocol) {
        showLoadingSpinner()
        fetchAgreements(cardId) { [weak self] result in
            switch result {
            case let .success(agreementKeys):
                self?.acceptAgreements(agreementKeys)
            case let .failure(error):
                self?.show(error: error)
                self?.hideLoadingSpinner()
            }
        }
    }

    private func fetchAgreements(_ cardId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        serviceLocator
            .platform
            .fetchCard(cardId, forceRefresh: false) { [weak self] result in
                switch result {
                case let .success(card):
                    if let agreementKeys = card.features?.achAccount?.disclaimer?.agreementKeys {
                        completion(.success(agreementKeys))
                    } else {
                        completion(.failure(AgreementError.noKeysAvailables))
                    }
                case let .failure(error):
                    completion(.failure(error))
                    self?.hideLoadingSpinner()
                }
            }
    }

    private func acceptAgreements(_ agreements: [String]) {
        let agreementRequest = AgreementRequest(key: agreements, userAction: .accepted)
        serviceLocator
            .platform
            .reviewAgreement(agreementRequest) { [weak self, cardId] result in
                switch result {
                case .success:
                    self?.getBalance(cardId: cardId)
                case let .failure(error):
                    self?.show(error: error)
                    self?.hideLoadingSpinner()
                }
            }
    }

    private func getBalance(cardId: String) {
        serviceLocator
            .platform
            .fetchCardFundingSource(cardId, forceRefresh: false) { [weak self] result in
                switch result {
                case let .success(source):
                    if let balanceId = source?.fundingSourceId {
                        self?.createAccount(balanceId: balanceId)
                    } else {
                        self?.show(error: AgreementError.balanceIdNotFound)
                        self?.hideLoadingSpinner()
                    }
                case let .failure(error):
                    self?.show(error: error)
                    self?.hideLoadingSpinner()
                }
            }
    }

    private func createAccount(balanceId: String) {
        serviceLocator
            .platform
            .assignAchAccount(balanceId: balanceId) { [weak self] result in
                switch result {
                case .success:
                    self?.finish()
                case let .failure(error):
                    self?.show(error: error)
                }
                self?.hideLoadingSpinner()
            }
    }

    private func decline(completion: (() -> Void)?) {
        showLoadingSpinner()
        fetchAgreements(cardId) { [weak self] result in
            switch result {
            case let .success(agreementKeys):
                self?.declineAgreements(agreementKeys, completion: completion)
            case let .failure(error):
                self?.show(error: error)
                self?.hideLoadingSpinner()
            }
        }
    }

    private func declineAgreements(_ agreementKeys: [String], completion: (() -> Void)?) {
        let agreementRequest = AgreementRequest(key: agreementKeys, userAction: .declined)
        serviceLocator
            .platform
            .reviewAgreement(agreementRequest) { [weak self] result in
                switch result {
                case .success:
                    completion?()
                case let .failure(error):
                    self?.show(error: error)
                }
                self?.hideLoadingSpinner()
            }
    }

    private func confirmClose(onConfirm _: @escaping () -> Void) {
        analyticsManager?.track(event: Event.disclaimerRejectTap, properties: ["": ""])
        let cancelTitle = "disclaimer.disclaimer.cancel_action.cancel_button".podLocalized()
        let okTitle = "disclaimer.disclaimer.cancel_action.ok_button".podLocalized()
        // Invert the titles to have the cancel button on the right
        actionConfirmer.confirm(title: "disclaimer.disclaimer.cancel_action.title".podLocalized(),
                                message: "disclaimer.disclaimer.cancel_action.message".podLocalized(),
                                okTitle: cancelTitle,
                                cancelTitle: okTitle) { [weak self] action in
            guard let title = action.title, title != cancelTitle,
                  let self = self else { return }
            self.decline {
                self.onDeclineAgreements?()
            }
        }
    }
}
