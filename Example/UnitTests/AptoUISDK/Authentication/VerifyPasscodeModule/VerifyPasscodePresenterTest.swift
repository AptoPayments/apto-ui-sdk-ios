//
//  VerifyPasscodePresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class VerifyPasscodePresenterTest: XCTestCase {
    private var sut: VerifyPasscodePresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let router = VerifyPasscodeModuleSpy(serviceLocator: ServiceLocatorFake())
    private let interactor = VerifyPasscodeInteractorFake()
    private let analyticsManager = AnalyticsManagerSpy()
    private let code = "1111"
    private let config = VerifyPasscodePresenterConfig(logoURL: "https://aptopayments.com")

    override func setUp() {
        super.setUp()

        sut = VerifyPasscodePresenter(config: config)
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testViewLoadedTrackAnalytticsEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(Event.verifyPasscodeStart, analyticsManager.lastEvent)
    }

    func testViewLoadedUpdateViewModel() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertEqual(config.logoURL, sut.viewModel.logoURL.value)
    }

    func testPinEnteredCallInteractor() {
        // When
        sut.pinEntered(code)

        // Then
        XCTAssertTrue(interactor.verifyCodeCalled)
    }

    func testPINIsValidAskRouterToFinish() {
        // Given
        interactor.nextVerifyCodeResult = .success(true)

        // When
        sut.pinEntered(code)

        // Then
        XCTAssertTrue(router.finishCalled)
    }

    func testPINIsNotValidUpdateViewModelError() {
        // Given
        interactor.nextVerifyCodeResult = .success(false)

        // When
        sut.pinEntered(code)

        // Then
        XCTAssertFalse(router.finishCalled)
        XCTAssertNotNil(sut.viewModel.error.value)
    }

    func testForgotPINTappedAskRouterToShowForgotPIN() {
        // When
        sut.forgotPINTapped()

        // Then
        XCTAssertTrue(router.showForgotPINCalled)
    }
}
