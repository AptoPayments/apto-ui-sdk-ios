//
// CardWaitListModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class CardWaitListModuleTest: XCTestCase {
    private var sut: CardWaitListModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let card = ModelDataProvider.provider.waitListedCard
    private let cardProduct = ModelDataProvider.provider.cardProduct
    private lazy var presenter = serviceLocator.presenterLocatorFake.cardWaitListPresenterSpy
    private lazy var platform = serviceLocator.platformFake

    override func setUp() {
        super.setUp()

        sut = CardWaitListModule(serviceLocator: serviceLocator, card: card)
    }

    func testInitializeCallFetchCardProduct() {
        // When
        sut.initialize { _ in }

        // Then
        XCTAssertTrue(platform.fetchCardProductCalled)
    }

    func testCardProductLoadFailsCallbackFailure() {
        // Given
        platform.nextFetchCardProductResult = .failure(BackendError(code: .other))

        // When
        sut.initialize { result in
            // Then
            XCTAssertTrue(result.isFailure)
        }
    }

    func testCardProductLoadSucceedInitializeCallbackSuccess() {
        // Given
        platform.nextFetchCardProductResult = .success(cardProduct)

        // When
        sut.initialize { result in
            // Then
            XCTAssertTrue(result.isSuccess)
        }
    }

    func testInitializeSetUpPresenter() {
        // Given
        platform.nextFetchCardProductResult = .success(cardProduct)

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.router)
    }

    func testApplicationStatusChangedCallOnFinish() {
        // Given
        var onFinishCalled = false
        sut.onFinish = { _ in
            onFinishCalled = true
        }

        // When
        sut.cardStatusChanged()

        // Then
        XCTAssertTrue(onFinishCalled)
    }
}
