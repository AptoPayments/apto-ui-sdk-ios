//
//  ApplePayIAPViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 16/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class ApplePayIAPViewControllerTests: XCTestCase {
    let cardId = "crd_1234567890"

    func test_init_doesNotFetchCard() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCardInfoCallCount, 0)
    }

    func test_viewDidLoad_fetchCardData() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCardInfoCallCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line)
        ->
        (sut: ApplePayIAPViewController, loader: CardLoaderSpy)
    {
        let loader = CardLoaderSpy()
        let viewModel = ApplePayIAPViewModel(cardId: cardId, loader: loader)
        let sut = ApplePayIAPViewController(viewModel: viewModel, uiConfiguration: UIConfig.default)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
}
