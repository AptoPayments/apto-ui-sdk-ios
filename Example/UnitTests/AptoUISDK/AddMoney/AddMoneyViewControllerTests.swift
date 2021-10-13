//
//  AddMoneyViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 25/1/21.
//

import XCTest
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class AddMoneyViewControllerTests: XCTestCase {
    
    let cardId = "crd_1234567890"
    
    func test_init_rendersAddMoneyView() throws {
        let uiConfig = ModelDataProvider.provider.uiConfig
        let viewModel = AddMoneyViewModel(cardId: cardId, loader: CardLoaderSpy(), analyticsManager: AnalyticsManagerSpy())
        let sut = AddMoneyViewController(uiConfiguration: uiConfig, viewModel: viewModel)
        
        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.view)
        XCTAssertTrue(sut.view.subviews.count > 0)
        XCTAssertTrue(((sut.view.subviews.first?.isKind(of: AddMoneyView.self)) != nil))
    }
    
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

        XCTAssertFalse(sut.isActivityIndicatorLoading)
    }
    
    func test_loadCardInfoCompletion_loadsCardProductInfo() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCardInfoLoading()
        
        XCTAssertEqual(loader.loadCardInfoCallCount, 1)
    }
    
    func test_loadCardCompletion_rendersSuccessfullyLoadedInfo() {
        let card = ModelDataProvider.provider.cardWithACHAccount
        let cardProduct = ModelDataProvider.provider.cardProduct
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCardInfoLoading(with: card)

        let (debitCardTransferTitle, debitCardTransferSubtitle,
             directDepositTransferTitle, directDepositTransferSubtitle) = bottomSheetItems(cardProduct: cardProduct.name)
        
        XCTAssertEqual(sut.item1ActionDetailTitle, debitCardTransferTitle)
        XCTAssertEqual(sut.item1ActionDetailSubTitle, debitCardTransferSubtitle)
        XCTAssertEqual(sut.item2ActionDetailTitle, directDepositTransferTitle)
        XCTAssertEqual(sut.item2ActionDetailSubTitle, directDepositTransferSubtitle)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: AddMoneyViewController, loader: CardLoaderSpy) {
        let loader = CardLoaderSpy()
        let viewModel = AddMoneyViewModel(cardId: cardId, loader: loader, analyticsManager: AnalyticsManagerSpy())
        let sut = AddMoneyViewController(uiConfiguration: UIConfig.default, viewModel: viewModel)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func bottomSheetItems(cardProduct: String) -> (debitCardTransferTitle: String,
                                                           debitCardTransferSubtitle: String,
                                                           directDepositTransferTitle: String,
                                                           directDepositTransferSubtitle: String){
        return ("load_funds.selector_dialog.card.title".podLocalized(),
                "load_funds.selector_dialog.card.description".podLocalized(),
                "load_funds.selector_dialog.direct_deposit.title".podLocalized(),
                "load_funds.selector_dialog.direct_deposit.description".podLocalized().replace(["<<VALUE>>": cardProduct])
            )
        }
}

private extension AddMoneyViewController {
    var isActivityIndicatorLoading: Bool {
        return activityIndicator.isAnimating
    }
    var item1ActionDetailTitle: String? {
        return addMoneyView.item1ActionDetailView.titleLabel.text
    }
    var item1ActionDetailSubTitle: String? {
        return addMoneyView.item1ActionDetailView.subTitleLabel.text
    }
    var item2ActionDetailTitle: String? {
        return addMoneyView.item2ActionDetailView.titleLabel.text
    }
    var item2ActionDetailSubTitle: String? {
        return addMoneyView.item2ActionDetailView.subTitleLabel.text
    }
}

class ShowAgreementActionModuleSpy: UIModuleSpy {
    
}
