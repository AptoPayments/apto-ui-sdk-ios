//
//  ManageCardInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import AptoSDK
import Foundation

class ManageCardInteractor: ManageCardInteractorProtocol {
    private let platform: AptoPlatformProtocol
    private var card: Card

    init(platform: AptoPlatformProtocol, card: Card) {
        self.platform = platform
        self.card = card
    }

    func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback) {
        platform.fetchCardFundingSource(card.accountId, forceRefresh: forceRefresh) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(fundingSource):
                self.card.fundingSource = fundingSource
                callback(.success(self.card))
            }
        }
    }

    func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback) {
        platform.fetchCard(card.accountId, forceRefresh: true, retrieveBalances: true) { [weak self] result in
            guard let self = self else { return }
            callback(result.flatMap { [unowned self] financialAccount -> Result<Card, NSError> in
                guard let card = financialAccount as? Card else {
                    return .failure(ServiceError(code: .jsonError))
                }
                self.card = card
                return .success(card)
            })
        }
    }

    func isUserLoggedIn() -> Bool {
        platform.currentToken() != nil
    }

    func loadCardInfo(_ callback: @escaping Result<Card, NSError>.Callback) {
        callback(.success(card))
    }

    func activateCard(_ callback: @escaping Result<Card, NSError>.Callback) {
        platform.activateCard(card.accountId, callback: callback)
    }

    func isShowDetailedCardActivityEnabled() -> Bool {
        return platform.isShowDetailedCardActivityEnabled()
    }

    func provideTransactions(filters: TransactionListFilters,
                             forceRefresh: Bool,
                             callback: @escaping Result<[Transaction], NSError>.Callback)
    {
        platform.fetchCardTransactions(card.accountId, filters: filters, forceRefresh: forceRefresh, callback: callback)
    }

    func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
        platform.activatePhysicalCard(card.accountId, code: code) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(activationResult):
                if activationResult.type == .activated {
                    callback(.success(()))
                } else {
                    let error: BackendError
                    if let rawErrorCode = activationResult.errorCode,
                       let errorCode = BackendError.ErrorCodes(rawValue: rawErrorCode)
                    {
                        error = BackendError(code: errorCode)
                    } else {
                        // This should never happen
                        error = BackendError(code: .other)
                    }
                    callback(.failure(error))
                }
            }
        }
    }

    func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback) {
        platform.fetchCardFundingSources(card.accountId, page: nil, rows: nil, forceRefresh: true, callback: callback)
    }
}
