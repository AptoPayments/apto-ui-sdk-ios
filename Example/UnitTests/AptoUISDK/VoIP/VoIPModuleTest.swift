//
// VoIPModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/06/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class VoIPModuleTest: XCTestCase {
    private var sut: VoIPModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let card = ModelDataProvider.provider.card
    private let actionSource = VoIPActionSource.getPin

    override func setUp() {
        super.setUp()
        sut = VoIPModule(serviceLocator: serviceLocator, card: card, actionSource: actionSource)
    }

    func testInitializeCallbackSuccess() {
        // Given
        var returnedResult: Result<UIViewController, NSError>?

        // When
        sut.initialize { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testInitializeSetUpPresenter() {
        // Given
        let presenter = serviceLocator.presenterLocator.voIPPresenter()

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.analyticsManager)
    }

    func testCallFinishedCallClose() {
        // Given
        var finishCalled = false
        sut.onFinish = { _ in
            finishCalled = true
        }

        // When
        sut.callFinished()

        // Then
        XCTAssertTrue(finishCalled)
    }
}
