//
//  OrderPhysicalCardViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 25/3/21.
//

import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class OrderPhysicalCardViewControllerTests: XCTestCase {
    let cardId = "crd_1234567890"
    let emptyString = ""
    
    func test_init_doesNotLoadOrderCardConfig() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.orderCardConfigCallCount, 0)
    }

    func test_loadOrderPhysicalCard_requestCardConfigFromStorage() throws {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.orderCardConfigCallCount, 1)
        XCTAssertEqual(loader.orderCardCallCount, 0)
    }

    func test_loadOrderPhysicalCard_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isActivityIndicatorLoading)
    }

    func test_loadOrderPhysicalCardCompletion_hidesLoadingIndicator() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeOrderCardConfigLoading()
        
        XCTAssertFalse(sut.isActivityIndicatorLoading)
    }

    func test_loadOrderPhysicalCardCompletion_rendersSuccessfullyCardConfigData() {
        let config = ModelDataProvider.provider.physicalCardConfig
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeOrderCardConfigLoading(with: config)
        
        XCTAssertEqual(sut.cardFee, config.issuanceFee?.text)
    }
    
    func test_loadOrderPhysicalCardCompletion_rendersNoFeeWhenConfigDataContainsNoFee() {
        let config = ModelDataProvider.provider.physicalCardConfigNoFee
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeOrderCardConfigLoading(with: config)
        
        XCTAssertEqual(sut.cardFee, emptyString)
    }

    func test_orderPhysicalCardPerformOrder_requestsCardOrder() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateOrderCardAction()
        
        XCTAssertEqual(loader.orderCardCallCount, 1)
    }

    // MARK: Private methods
    private func makeSUT(
        _ card: Card = ModelDataProvider.provider.cardWithDataToRenderACreditCardView,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: OrderPhysicalCardViewController,
        loader: FinancialCardLoaderSpy) {
        let loader = FinancialCardLoaderSpy()
        let sut = OrderPhysicalCardUIComposer.composedWith(card: card,
                                                           cardLoader: loader,
                                                           analyticsManager: AnalyticsManagerSpy(),
                                                           uiConfiguration: UIConfig.default)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
}

private extension OrderPhysicalCardViewController {
    var isActivityIndicatorLoading: Bool {
        return activityIndicator.isAnimating
    }
    
    var cardFee: String? {
        return orderCardView.feeInfoView.valueLabel.text
    }
    
    func simulateOrderCardAction() {
        orderCardView.actionButton.simulateTap()
    }
}
