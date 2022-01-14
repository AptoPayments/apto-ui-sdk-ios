//
//  CardMonthlyStatsInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/01/2019.
//

import AptoSDK
import Foundation

class CardMonthlyStatsInteractor: CardMonthlyStatsInteractorProtocol {
    private let card: Card
    private let platform: AptoPlatformProtocol

    init(card: Card, platform: AptoPlatformProtocol) {
        self.card = card
        self.platform = platform
    }

    func fetchMonthlySpending(date: Date, callback: @escaping Result<MonthlySpending, NSError>.Callback) {
        platform.fetchMonthlySpending(cardId: card.accountId, month: date.month, year: date.year) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case var .success(spending):
                spending.date = date
                callback(.success(spending))
            }
        }
    }

    func isStatementsFeatureEnabled(callback: @escaping (Bool) -> Void) {
        callback(platform.isFeatureEnabled(.showMonthlyStatementsOption))
    }

    func fetchStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
        platform.fetchMonthlyStatementsPeriod(callback: callback)
    }
}
