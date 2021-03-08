//
//  CardLoaderSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 8/2/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import AptoSDK
@testable import AptoUISDK

class CardLoaderSpy: AptoPlatformFake {
    private var cardCompletions = [(Result<Card, NSError>) -> Void]()
    private var cardProductCompletions = [(Result<CardProduct, NSError>) -> Void]()
    
    var loadCardInfoCallCount: Int {
        cardCompletions.count
    }
    
    var loadCardProductCallCount: Int {
        cardProductCompletions.count
    }

    override func fetchCard(_ cardId: String, forceRefresh: Bool, retrieveBalances: Bool, callback: @escaping Result<Card, NSError>.Callback) {
        cardCompletions.append(callback)
    }
    
    override func fetchCardProduct(cardProductId: String, forceRefresh: Bool, callback: @escaping Result<CardProduct, NSError>.Callback) {
        cardProductCompletions.append(callback)
    }
    
    func completeCardInfoLoading(with card: Card = ModelDataProvider.provider.cardWithACHAccount, at index: Int = 0) {
        cardCompletions[index](.success(card))
    }

    func completeCardProductLoading(with cardProduct: CardProduct = ModelDataProvider.provider.cardProduct, at index: Int = 0) {
        cardProductCompletions[index](.success(cardProduct))
    }
}
