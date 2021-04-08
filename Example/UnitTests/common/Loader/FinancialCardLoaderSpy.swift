//
//  FinancialCardLoaderSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 25/3/21.
//

import Foundation
@testable import AptoSDK
@testable import AptoUISDK

class FinancialCardLoaderSpy: AptoPlatformFake {
    private var orderCardCompletion = [(Result<Card, NSError>) -> Void]()
    private var orderCardConfigCompletion = [(Result<PhysicalCardConfig, NSError>) -> Void]()
    
    var orderCardCallCount: Int {
        orderCardCompletion.count
    }
    
    var orderCardConfigCallCount: Int {
        orderCardConfigCompletion.count
    }
    
    override func orderPhysicalCard(_ cardId: String, callback: @escaping (Result<Card, NSError>) -> Void) {
        orderCardCompletion.append(callback)
    }
    
    override func getOrderPhysicalCardConfig(_ cardId: String, callback: @escaping (Result<PhysicalCardConfig, NSError>) -> Void) {
        orderCardConfigCompletion.append(callback)
    }
    
    override func currentToken() -> AccessToken? {
        AccessToken(token: "a user token", primaryCredential: nil, secondaryCredential: nil)
    }
    
    func completeOrderCardLoading(with card: Card = ModelDataProvider.provider.cardWithACHAccount, at index: Int = 0) {
        orderCardCompletion[index](.success(card))
    }
    
    func completeOrderCardConfigLoading(with cardConfig: PhysicalCardConfig = ModelDataProvider.provider.physicalCardConfig, at index: Int = 0) {
        orderCardConfigCompletion[index](.success(cardConfig))
    }
}
