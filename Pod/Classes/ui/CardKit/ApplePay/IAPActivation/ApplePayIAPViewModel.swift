//
//  ApplePaySplashViewModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 16/4/21.
//

import AptoSDK
import Foundation

public final class ApplePayIAPViewModel {
    typealias Observer<T> = (T) -> Void

    private let loader: AptoPlatformProtocol
    private let cardId: String
    var onLoadingStateChange: Observer<Bool>?
    var onCardFetched: Observer<Card>?
    var onCardError: Observer<NSError>?
    var onPayloadFetched: Observer<ApplePayIAPIssuerResponse>?
    var onPayloadError: Observer<NSError>?

    init(cardId: String, loader: AptoPlatformProtocol) {
        self.cardId = cardId
        self.loader = loader
    }

    func loadCard() {
        onLoadingStateChange?(true)
        loader.fetchCard(cardId, forceRefresh: false) { [weak self] result in
            switch result {
            case let .success(card):
                self?.onCardFetched?(card)
            case let .failure(error):
                self?.onCardError?(error)
            }
            self?.onLoadingStateChange?(false)
        }
    }

    func sendRequestData(certificates: [Data],
                         nonce: Data,
                         nonceSignature: Data,
                         completion: @escaping (ApplePayIAPIssuerResponse) -> Void)
    {
        onLoadingStateChange?(true)
        loader.startApplePayInAppProvisioning(cardId: cardId,
                                              certificates: certificates,
                                              nonce: nonce,
                                              nonceSignature: nonceSignature) { [weak self] result in
            switch result {
            case let .success(responsePayload):
                completion(responsePayload)
                self?.onPayloadFetched?(responsePayload)
            case let .failure(error):
                self?.onPayloadError?(error)
            }
        }
    }
}
