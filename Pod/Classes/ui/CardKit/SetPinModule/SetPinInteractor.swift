//
// SetPinInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/06/2019.
//

import Foundation
import AptoSDK

class SetPinInteractor: SetPinInteractorProtocol {
  private let platform: AptoPlatformProtocol
  private let card: Card

  init(platform: AptoPlatformProtocol, card: Card) {
    self.platform = platform
    self.card = card
  }

  func changePin(_ pin: String, completion: @escaping Result<Card, NSError>.Callback) {
    platform.changeCardPIN(card.accountId, pin: pin, callback: completion)
  }
}
