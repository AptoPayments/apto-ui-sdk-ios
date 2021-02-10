//
//  DirectDepositViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 27/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class DirectDepositViewControllerTests: XCTestCase {

    let cardId = "crd_1234567890"
    
    func test_init_doesNotLoadCardInfo() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCardInfoCallCount, 0)
    }

    func test_viewDidLoad_loadsCardInfo() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCardInfoCallCount, 1)
    }
    
    func test_loadCardInfo_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isActivityIndicatorLoading)
    }
    
    func test_loadCardCompletion_hidesLoadingIndicator() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCardInfoLoading()
        loader.completeCardProductLoading()

        XCTAssertFalse(sut.isActivityIndicatorLoading)
    }
    
    func test_loadCardInfoCompletion_loadsCardProductInfo() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCardInfoLoading()
        loader.completeCardProductLoading()
        
        XCTAssertEqual(loader.loadCardInfoCallCount, 1)
        XCTAssertEqual(loader.loadCardProductCallCount, 1)
    }
    
    func test_loadCardCompletion_rendersSuccessfullyLoadedInfo() {
        let card = ModelDataProvider.provider.cardWithBankAccount
        let cardProduct = ModelDataProvider.provider.cardProduct
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCardInfoLoading(with: card)
        loader.completeCardProductLoading(with: cardProduct)

        XCTAssertEqual(sut.accountNumber, card.features?.bankAccount?.bankAccountDetails?.accountNumber)
        XCTAssertEqual(sut.routingNumber, card.features?.bankAccount?.bankAccountDetails?.routingNumber)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: DirectDepositViewController, loader: CardLoaderSpy) {
        let loader = CardLoaderSpy()
        let sut = DirectDepositViewController(uiConfiguration: UIConfig.default, cardId: cardId, loader: loader, analyticsManager: AnalyticsManagerSpy())
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
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
        
        func completeCardInfoLoading(with card: Card = ModelDataProvider.provider.cardWithBankAccount, at index: Int = 0) {
            cardCompletions[index](.success(card))
        }

        func completeCardProductLoading(with cardProduct: CardProduct = ModelDataProvider.provider.cardProduct, at index: Int = 0) {
            cardProductCompletions[index](.success(cardProduct))
        }
    }
}

private extension DirectDepositViewController {
    var isActivityIndicatorLoading: Bool {
        return mainView.activityIndicator.isAnimating
    }

    var accountNumber: String? {
        return mainView.accountNumberInfoView.valueLabel.text
    }

    var routingNumber: String? {
        return mainView.routingNumberInfoView.valueLabel.text
    }
}