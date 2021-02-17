//
//  DirectDepositViewModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 4/2/21.
//

import Foundation
import AptoSDK

final class DirectDepositViewModel {
    private let loader: AptoPlatformProtocol
    private let analyticsManager: AnalyticsServiceProtocol
    private let cardId: String
    typealias Observer<T> = (T) -> Void

    var onCardLoadingStateChange: Observer<Bool>?
    var onErrorCardLoading: Observer<NSError>?
    var onCardLoadedSuccessfully: Observer<DirectDepositViewData>?

    init(cardId: String, loader: AptoPlatformProtocol, analyticsManager: AnalyticsServiceProtocol) {
        self.loader = loader
        self.cardId = cardId
        self.analyticsManager = analyticsManager
    }
    
    public func load() {
        onCardLoadingStateChange?(true)
        loader
            .fetchCard(cardId,
                       forceRefresh: false,
                       retrieveBalances: false,
                       callback: { [weak self] cardResult in
                        switch cardResult {
                        case .success(let card):
                            self?.fetchCardProduct(card: card)
                        case .failure(let error):
                            self?.onErrorCardLoading?(error)
                            self?.onCardLoadingStateChange?(false)
                        }
                       })
    }
    
    public func trackEvent() {
        analyticsManager.track(event: .directDepositStart)
    }
    
    private func fetchCardProduct(card: Card) {
        if let productId = card.cardProductId {
            loader
                .fetchCardProduct(cardProductId: productId,
                                  forceRefresh: false,
                                  callback: { [weak self] result in
                                    switch result {
                                    case .success(let cardProduct):
                                        if let viewData = DirectDepositViewDataMapper.map(card: card, cardProduct: cardProduct) {
                                            self?.onCardLoadedSuccessfully?(viewData)
                                        }
                                    case .failure(let error):
                                        self?.onErrorCardLoading?(error)
                                    }
                                    self?.onCardLoadingStateChange?(false)
                                  })
        }
    }
}

public struct DirectDepositViewData {
    let accountDetails: BankAccountDetails
    let description: String
    let footer: String
}

struct DirectDepositViewDataMapper {
    private init() {}
    public static func map(card: Card, cardProduct: CardProduct) -> DirectDepositViewData? {
        guard let accountDetails = card.features?.bankAccount?.bankAccountDetails else { return nil }
        let description = "load_funds.direct_deposit.instructions_description".podLocalized().replace(["<<APP_NAME>>": cardProduct.name])
        let footer = "load_funds.direct_deposit.footer.description".podLocalized().replace(["<<APP_NAME>>": cardProduct.name])
        return DirectDepositViewData(accountDetails: accountDetails, description: description, footer: footer)
    }
}
