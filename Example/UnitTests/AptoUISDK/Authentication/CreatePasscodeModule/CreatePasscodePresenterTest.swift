//
//  CreatePasscodePresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class CreatePasscodePresenterTest: XCTestCase {
    private var sut: CreatePasscodePresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let router = CreatePasscodeModuleSpy(serviceLocator: ServiceLocatorFake())
    private let interactor = CreatePasscodeInteractorFake()
    private let analyticsManager = AnalyticsManagerSpy()
    private let code = "1111"

    override func setUp() {
        super.setUp()

        sut = CreatePasscodePresenter()
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testViewLoadedTrackEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(Event.createPasscodeStart, analyticsManager.lastEvent)
    }

    func testCloseTappedCallClose() {
        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(router.closeCalled)
    }

    func testPINEnteredCallInteractor() {
        // When
        sut.pinEntered(code)

        // Then
        XCTAssertTrue(interactor.saveCodeCalled)
        XCTAssertEqual(code, interactor.lastSaveCode)
    }

    func testSavePINSucceedAskRouterToFinish() {
        // Given
        interactor.nextSaveCodeResult = .success(())

        // When
        sut.pinEntered(code)

        // Then
        XCTAssertTrue(router.finishCalled)
    }

    func testSavePINFailsUpdateErrorProperty() {
        // Given
        interactor.nextSaveCodeResult = .failure(BackendError(code: .other))

        // When
        sut.pinEntered(code)

        // Then
        XCTAssertNotNil(sut.viewModel.error.value)
    }
}
