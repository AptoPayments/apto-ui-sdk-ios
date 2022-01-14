//
// VoIPInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/06/2019.
//

import AptoSDK
import Foundation

class VoIPInteractor: VoIPInteractorProtocol {
    private let platform: AptoPlatformProtocol
    private let card: Card
    private let actionSource: VoIPActionSource

    init(platform: AptoPlatformProtocol, card: Card, actionSource: VoIPActionSource) {
        self.platform = platform
        self.card = card
        self.actionSource = actionSource
    }

    func fetchVoIPToken(callback: @escaping Result<VoIPToken, NSError>.Callback) {
        platform.fetchVoIPToken(cardId: card.accountId, actionSource: actionSource, callback: callback)
    }
}
