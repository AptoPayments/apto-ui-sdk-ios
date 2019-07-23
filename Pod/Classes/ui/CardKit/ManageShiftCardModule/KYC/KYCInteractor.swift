//
//  KYCInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 9/04/2018.
//
//

import Foundation
import AptoSDK

class KYCInteractor: KYCInteractorProtocol {
  private let platform: AptoPlatformProtocol
  private let card: Card

  init(platform: AptoPlatformProtocol, card: Card) {
    self.platform = platform
    self.card = card
  }

  func provideKYCInfo(_ callback: @escaping Result<KYCState?, NSError>.Callback) {
    platform.fetchFinancialAccount(card.accountId, retrieveBalances: false) { result in
      callback(result.flatMap { financialAccount -> Result<KYCState?, NSError> in
        if let card = financialAccount as? Card {
          return .success(card.kyc)
        }
        else {
          return .success(nil)
        }
      })
    }
  }
}
