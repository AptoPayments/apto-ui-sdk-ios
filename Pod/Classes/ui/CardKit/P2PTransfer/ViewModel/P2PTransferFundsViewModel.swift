//
//  P2PTransferFundsViewModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 6/9/21.
//

import Foundation
import AptoSDK
import CoreImage

class P2PTransferFundsViewModel {
    private let loader: AptoPlatformProtocol
    private let cardId: String
    typealias Observer<T> = (T) -> Void

    var onLoadingStateChange: Observer<Bool>?
    var onErrorRequest: Observer<NSError>?
    var onBalanceFetched: Observer<FundingSource>?
    var onTransferDone: Observer<P2PTransferResponse>?

    private var balance: FundingSource?
    
    init(loader: AptoPlatformProtocol, cardId: String) {
        self.loader = loader
        self.cardId = cardId
    }

    // MARK: Public methods
    public func fetchFundingSource() {
        onLoadingStateChange?(true)
        loader.fetchCardFundingSource(cardId,
                                      forceRefresh: false) { [weak self] result in
            switch result {
            case .success(let fundingSource):
                if let fundingSource = fundingSource {
                    self?.balance = fundingSource
                    self?.onBalanceFetched?(fundingSource)
                }
            case .failure(let error):
                self?.onErrorRequest?(error)
            }
            self?.onLoadingStateChange?(false)
        }
    }
    
    public func performTransferRequest(model: P2PTransferRequest) {
        onLoadingStateChange?(true)
        loader.p2pMakeTransfer(transferRequest: model) { [weak self] result in
            switch result {
            case .success(let response):
                self?.onTransferDone?(response)
            case .failure(let error):
                self?.onErrorRequest?(error)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
