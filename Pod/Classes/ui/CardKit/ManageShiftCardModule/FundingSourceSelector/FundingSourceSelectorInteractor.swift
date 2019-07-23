//
// FundingSourceSelectorInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import Foundation
import AptoSDK

class FundingSourceSelectorInteractor: FundingSourceSelectorInteractorProtocol {
  private let card: Card
  private let platform: AptoPlatformProtocol

  init(card: Card, platform: AptoPlatformProtocol) {
    self.card = card
    self.platform = platform
  }

  func loadFundingSources(forceRefresh: Bool, callback: @escaping Result<[FundingSource], NSError>.Callback) {
    platform.fetchCardFundingSources(card.accountId, page: nil, rows: nil, forceRefresh: forceRefresh,
                                     callback: callback)
  }

  func activeCardFundingSource(forceRefresh: Bool, callback: @escaping Result<FundingSource?, NSError>.Callback) {
    platform.fetchCardFundingSource(card.accountId, forceRefresh: forceRefresh, callback: callback)
  }

  func setActive(fundingSource: FundingSource, callback: @escaping Result<FundingSource, NSError>.Callback) {
    platform.setCardFundingSource(fundingSource.fundingSourceId, cardId: card.accountId, callback: callback)
  }
}
