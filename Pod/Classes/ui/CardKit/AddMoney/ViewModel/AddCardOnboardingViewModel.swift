//
//  AddCardOnboardingViewModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 15/6/21.
//

import AptoSDK
import Foundation

struct OnBoardingCardData {
    let cardName: String?
    let softDescriptor: String?
}

final class AddCardOnboardingViewModel {
    private let loader: AptoPlatformProtocol
    private let cardId: String
    typealias Observer<T> = (T) -> Void

    var onCardLoadingStateChange: Observer<Bool>?
    var onErrorCardLoading: Observer<NSError>?
    var onCardInfoLoadedSuccessfully: Observer<OnBoardingCardData>?

    init(cardId: String, loader: AptoPlatformProtocol) {
        self.loader = loader
        self.cardId = cardId
    }

    // swiftlint:disable trailing_closure
    public func fetchInfo() {
        onCardLoadingStateChange?(true)
        loader
            .fetchCard(cardId,
                       forceRefresh: false,
                       retrieveBalances: false,
                       callback: { [weak self] cardResult in
                           switch cardResult {
                           case let .success(card):
                               let descriptor = card.features?.funding?.softDescriptor ?? ""
                               guard let cardProductId = card.cardProductId else {
                                   self?.onCardInfoLoadedSuccessfully?(OnBoardingCardData(cardName: "",
                                                                                          softDescriptor: descriptor))
                                   return
                               }
                               self?.fetchCompanyName(cardProductId: cardProductId, descriptor: descriptor)
                           case let .failure(error):
                               self?.onErrorCardLoading?(error)
                           }
                           self?.onCardLoadingStateChange?(false)
                       })
    }

    // swiftlint:enable trailing_closure

    public func fetchCompanyName(cardProductId: String, descriptor: String) {
        loader.fetchCardProduct(cardProductId: cardProductId,
                                forceRefresh: false) { [weak self] result in
            switch result {
            case let .success(cardProduct):
                self?.onCardInfoLoadedSuccessfully?(OnBoardingCardData(cardName: cardProduct.name,
                                                                       softDescriptor: descriptor))
            case let .failure(error):
                self?.onErrorCardLoading?(error)
            }
        }
    }
}
