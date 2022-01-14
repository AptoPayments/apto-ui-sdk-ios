//
// CardWaitListInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import AptoSDK

class CardWaitListInteractor: CardWaitListInteractorProtocol {
    private let platform: AptoPlatformProtocol
    private let card: Card

    init(platform: AptoPlatformProtocol, card: Card) {
        self.platform = platform
        self.card = card
    }

    func reloadCard(completion: @escaping Result<Card, NSError>.Callback) {
        platform.fetchCard(card.accountId, forceRefresh: true) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(financialAccount):
                guard let card = financialAccount as? Card else {
                    completion(.failure(BackendError(code: .incorrectParameters)))
                    return
                }
                completion(.success(card))
            }
        }
    }
}
