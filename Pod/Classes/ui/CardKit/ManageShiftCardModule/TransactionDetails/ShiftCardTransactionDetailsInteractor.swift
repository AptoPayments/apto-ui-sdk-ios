//
//  ShiftCardTransactionDetailsInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation
import AptoSDK

class ShiftCardTransactionDetailsInteractor: ShiftCardTransactionDetailsInteractorProtocol {
  private let transaction: Transaction

  init(transaction: Transaction) {
    self.transaction = transaction
  }

  func provideTransaction(callback: @escaping Result<Transaction, NSError>.Callback) {
    callback(.success(transaction))
  }
}
