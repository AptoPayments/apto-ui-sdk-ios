//
//  DirectDepositViewModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 4/2/21.
//

import AptoSDK
import Foundation

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

    // swiftlint:disable trailing_closure
    public func load() {
        onCardLoadingStateChange?(true)
        loader
            .fetchCard(cardId,
                       forceRefresh: false,
                       retrieveBalances: false,
                       callback: { [weak self] cardResult in
                           switch cardResult {
                           case let .success(card):
                               if let viewData = DirectDepositViewDataMapper.map(card: card) {
                                   self?.onCardLoadedSuccessfully?(viewData)
                               } else {
                                   self?.onErrorCardLoading?(BackendError(code: .incorrectParameters))
                               }
                           case let .failure(error):
                               self?.onErrorCardLoading?(error)
                           }
                           self?.onCardLoadingStateChange?(false)
                       })
    }

    // swiftlint:enable trailing_closure

    public func trackEvent() {
        analyticsManager.track(event: .directDepositStart)
    }
}

public struct DirectDepositViewData {
    let accountDetails: ACHAccountDetails
    let description: String
    let footer: String
}

struct DirectDepositViewDataMapper {
    private init() {}
    public static func map(card: Card) -> DirectDepositViewData? {
        guard let accountDetails = card.features?.achAccount?.achAccountDetails else { return nil }
        let description = "load_funds.direct_deposit.instructions_description".podLocalized()
        let footer = "load_funds.direct_deposit.footer.description".podLocalized()
        return DirectDepositViewData(accountDetails: accountDetails, description: description, footer: footer)
    }
}
