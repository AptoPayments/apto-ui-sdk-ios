//
//  AddCardOnboardingViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 17/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class AddCardOnboardingViewControllerTests: XCTestCase {

    let cardId = "crd_1234567890"

    func test_init_doesNotFetchCardInfo() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCardInfoCallCount, 0)
    }

    func test_viewDidLoad_fetchesCardInfo() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCardInfoCallCount, 1)
    }

    func test_fetchCardInfoCompletion_fetchesCardProductInfo() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCardInfoLoading()
        loader.completeCardProductLoading()
        
        XCTAssertEqual(loader.loadCardInfoCallCount, 1)
        XCTAssertEqual(loader.loadCardProductCallCount, 1)
    }
    
    func test_loadCardCompletion_rendersSuccessfullyLoadedInfo() {
        let card = ModelDataProvider.provider.cardWithFunding
        let cardProduct = ModelDataProvider.provider.cardProduct
        
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeCardInfoLoading(with: card)
        loader.completeCardProductLoading(with: cardProduct)
        
        let header = "Debit Card"
        let firstParagraph = "You can instantly transfer funds from your existing bank debit card to your <<VALUE>> card account. Please note that transfers are reviewed and they can be delayed or declined if we suspect risks.".replace(["<<VALUE>>": cardProduct.name])
        let secondParagraph = "This transaction will appear in your bank account statement as: <<VALUE>>".replace(["<<VALUE>>": card.features?.funding?.softDescriptor ?? ""])
        XCTAssertEqual(sut.header, header)
        XCTAssertEqual(sut.firstParagraph, firstParagraph)
        XCTAssertEqual(sut.secondParagraph, secondParagraph)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: AddCardOnboardingViewController, loader: CardLoaderSpy) {
        let loader = CardLoaderSpy()
        let viewModel = AddCardOnboardingViewModel(cardId: cardId, loader: loader)
        let sut = AddCardOnboardingViewController(uiConfiguration: UIConfig.default, viewModel: viewModel)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
}

private extension AddCardOnboardingViewController {
    var header: String? {
        return mainView.headerLabel.text
    }
    var firstParagraph: String? {
        return mainView.firstParagraphLabel.text
    }
    var secondParagraph: String? {
        return mainView.secondParagraphLabel.text
    }
}
