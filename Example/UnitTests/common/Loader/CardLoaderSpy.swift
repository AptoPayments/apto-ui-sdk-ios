//
//  CardLoaderSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 8/2/21.
//

import Foundation
@testable import AptoSDK
@testable import AptoUISDK

class CardLoaderSpy: AptoPlatformFake {
    private var cardCompletions = [(Result<Card, NSError>) -> Void]()
    
    var loadCardInfoCallCount: Int {
        cardCompletions.count
    }
    
    override func fetchCard(_ cardId: String, forceRefresh: Bool, retrieveBalances: Bool, callback: @escaping Result<Card, NSError>.Callback) {
        cardCompletions.append(callback)
    }
    
    func completeCardInfoLoading(with card: Card = ModelDataProvider.provider.cardWithACHAccount, at index: Int = 0) {
        cardCompletions[index](.success(card))
    }

}
