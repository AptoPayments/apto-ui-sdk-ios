//
//  AddMoneyViewModel.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 8/2/21.
//

import Foundation
import AptoSDK

final class AddMoneyViewModel {
    private let loader: AptoPlatformProtocol
    private let analyticsManager: AnalyticsServiceProtocol
    private let cardId: String
    typealias Observer<T> = (T) -> Void

    var onCardLoadingStateChange: Observer<Bool>?
    var onErrorCardLoading: Observer<NSError>?
    var onCardProductNameLoadedSuccessfully: Observer<String>?

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
        analyticsManager.track(event: .addFundsSelectorStart)
    }
    
    private func fetchCardProduct(card: Card) {
        if let productId = card.cardProductId {
            loader
                .fetchCardProduct(cardProductId: productId,
                                  forceRefresh: false,
                                  callback: { [weak self] result in
                                    switch result {
                                    case .success(let cardProduct):
                                        self?.onCardProductNameLoadedSuccessfully?(cardProduct.name)
                                    case .failure(let error):
                                        self?.onErrorCardLoading?(error)
                                    }
                                    self?.onCardLoadingStateChange?(false)
                                  })
        }
    }
}
