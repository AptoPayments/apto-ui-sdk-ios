//
//  AptoCardTransactionDetailsInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import AptoSDK
import Foundation

class AptoCardTransactionDetailsInteractor: AptoCardTransactionDetailsInteractorProtocol {
    private let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
    }

    func provideTransaction(callback: @escaping Result<Transaction, NSError>.Callback) {
        callback(.success(transaction))
    }
}
