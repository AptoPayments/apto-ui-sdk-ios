//
//  PhysicalCardActivationSucceedInteractor.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import AptoSDK
import Foundation

class PhysicalCardActivationSucceedInteractor: PhysicalCardActivationSucceedInteractorProtocol {
    private let card: Card

    init(card: Card) {
        self.card = card
    }

    func provideCard(callback: (_ card: Card) -> Void) {
        callback(card)
    }
}
