//
// WaitListModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 27/02/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class WaitListModuleTest: XCTestCase {
    private var sut: WaitListModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let cardApplication = ModelDataProvider.provider.waitListCardApplication
    private lazy var presenter = serviceLocator.presenterLocatorFake.waitListPresenterSpy

    override func setUp() {
        super.setUp()

        sut = WaitListModule(serviceLocator: serviceLocator, cardApplication: cardApplication)
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
        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.analyticsManager)
    }

    func testApplicationStatusChangedCallOnFinish() {
        // Given
        var onFinishCalled = false
        sut.onFinish = { _ in
            onFinishCalled = true
        }

        // When
        sut.applicationStatusChanged()

        // Then
        XCTAssertTrue(onFinishCalled)
    }
}
