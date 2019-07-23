//
//  TransactionListInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/01/2019.
//

import AptoSDK

class TransactionListInteractor: TransactionListInteractorProtocol {
  private let card: Card
  private let platform: AptoPlatformProtocol

  init(card: Card, platform: AptoPlatformProtocol) {
    self.card = card
    self.platform = platform
  }

  func fetchTransactions(filters: TransactionListFilters, callback: @escaping Result<[Transaction], NSError>.Callback) {
    platform.fetchCardTransactions(card.accountId, filters: filters, forceRefresh: true, callback: callback)
  }
}
