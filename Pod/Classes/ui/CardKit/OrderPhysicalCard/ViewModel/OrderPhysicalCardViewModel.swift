//
//  OrderPhysicalCardViewModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 25/3/21.
//

import Foundation
import AptoSDK

final class OrderPhysicalCardViewModel {
    typealias Observer<T> = (T) -> Void

    enum OrderPhysicalCardError: Error {
        case internalError
    }
    
    private let loader: AptoPlatformProtocol
    private let card: Card
    private let analyticsManager: AnalyticsServiceProtocol
    var onOrderCardLoadingStateChange: Observer<Bool>?
    var onOrderCardConfigLoaded: Observer<OrderPhysicalCardViewData>?
    var onCardOrdered: Observer<Card>?
    var onOrderCardError: Observer<NSError>?
    var onOrderCardConfigError: Observer<NSError>?

    init(card: Card, loader: AptoPlatformProtocol, analyticsManager: AnalyticsServiceProtocol) {
        self.loader = loader
        self.card = card
        self.analyticsManager = analyticsManager
    }
    
    func loadConfig() {
        onOrderCardLoadingStateChange?(true)
        loader.getOrderPhysicalCardConfig(card.accountId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let config):
                do {
                    let viewData = OrderPhysicalCardViewData(card: self.card,
                                                             config: config,
                                                             pciConfiguration: try self.makePCIConfiguration(card: self.card))
                    self.onOrderCardConfigLoaded?(viewData)
                } catch {
                    self.onOrderCardError?(ServiceError(code: .internalIncosistencyError))
                }
            case .failure(let error):
                self.onOrderCardConfigError?(error)
            }
            self.onOrderCardLoadingStateChange?(false)
        }
    }
    
    func performCardOrder() {
        onOrderCardLoadingStateChange?(true)
        loader.orderPhysicalCard(card.accountId) { [onCardOrdered,
                                                    onOrderCardError,
                                                    onOrderCardLoadingStateChange] result in
            switch result {
            case .success(let card):
                onCardOrdered?(card)
            case .failure(let error):
                onOrderCardError?(error)
            }
            onOrderCardLoadingStateChange?(false)
        }
    }
    
    func track(event: Event, properties: [String: Any]? = nil) {
        analyticsManager.track(event: event, properties: properties)
    }
    
    // MARK: Private methods
    private func makePCIConfiguration(card: Card) throws -> PCIConfiguration {
        guard let token = loader.currentToken()?.token else {
            throw OrderPhysicalCardError.internalError
        }
        return PCIConfiguration(
            apiKey: AptoPlatform.defaultManager().apiKey,
            userToken: token,
            cardId: card.accountId,
            lastFour: card.lastFourDigits,
            name: card.cardHolder,
            environment: .local
        )
    }
}

public struct OrderPhysicalCardViewData {
    let card: Card
    let config: PhysicalCardConfig
    let pciConfiguration: PCIConfiguration
}
