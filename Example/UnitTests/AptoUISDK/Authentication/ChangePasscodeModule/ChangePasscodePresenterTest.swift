//
//  ChangePasscodePresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 13/02/2020.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class ChangePasscodePresenterTest: XCTestCase {
    private var sut: ChangePasscodePresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let router = ChangePasscodeModuleSpy(serviceLocator: ServiceLocatorFake())
    private let interactor = ChangePasscodeInteractorFake()
    private let analyticsManager = AnalyticsManagerSpy()
    private let passcode = "1111"

    override func setUp() {
        super.setUp()

        sut = ChangePasscodePresenter()
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testViewLoadedTrackEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(.changePasscodeStart, analyticsManager.lastEvent)
    }

    func testCloseTappedAskRouterToClose() {
        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(router.closeCalled)
    }

    func testInitialStepIsVerifyPasscode() {
        // Then
        XCTAssertEqual(.verifyPasscode, sut.viewModel.step.value)
    }

    func testVerifyPasscodePasscodeEnteredAskInteractorToVerifyCode() {
        // When
        sut.passcodeEntered(passcode)

        // Then
        XCTAssertTrue(interactor.verifyCodeCalled)
        XCTAssertEqual(passcode, interactor.lastVerifyCode)
    }

    // MARK: - Verify passcode

    func testVerifyCodeSucceedSetStepToSetPasscode() {
        // Given
        interactor.nextVerifyCodeResult = .success(true)

        // When
        sut.passcodeEntered(passcode)

        // Then
        XCTAssertEqual(.setPasscode, sut.viewModel.step.value)
    }

    func testVerifyPasscodeFailsSetErrorProperty() {
        // Given
        interactor.nextVerifyCodeResult = .success(false)

        // When
        sut.passcodeEntered(passcode)

        // Then
        XCTAssertNotNil(sut.viewModel.error.value)
        XCTAssertTrue(sut.viewModel.error.value is WrongPINError)
    }

    // MARK: - Set new passcode

    func testPasscodeVerifiedEnterPasscodeSetStepToConfirmPasscode() {
        // Given
        givenPasscodeVerified()

        // When
        sut.passcodeEntered(passcode)

        // Then
        XCTAssertEqual(.confirmPasscode, sut.viewModel.step.value)
    }

    // MARK: - Confirm passcode

    func testNewPasscodeSetDifferentPasscodeEnteredGoBackToSetPasscodeAndShowError() {
        // Given
        givenNewPasscodeSet()

        // When
        sut.passcodeEntered("wrong passcode")

        // Then
        XCTAssertEqual(.setPasscode, sut.viewModel.step.value)
        XCTAssertNotNil(sut.viewModel.error.value)
        XCTAssertTrue(sut.viewModel.error.value is PasscodeDoNotMatchError)
        XCTAssertFalse(interactor.saveCodeCalled)
    }

    func testNewPasscodeSetExpectedPasscodeEnteredAskInteractorToSaveNewCode() {
        // Given
        givenNewPasscodeSet()

        // When
        sut.passcodeEntered(passcode)

        // Then
        XCTAssertTrue(interactor.saveCodeCalled)
    }

    func testSavePasscodeSucceedAskRouterToFinish() {
        // Given
        interactor.nextSaveCodeResult = .success(())
        givenNewPasscodeSet()

        // When
        sut.passcodeEntered(passcode)

        // Then
        XCTAssertTrue(router.finishCalled)
    }

    func testSavePasscodeFailGoBackToSetPasscodeAndShowError() {
        // Given
        let error = BackendError(code: .other)
        interactor.nextSaveCodeResult = .failure(error)
        givenNewPasscodeSet()

        // When
        sut.passcodeEntered(passcode)

        // Then
        XCTAssertEqual(.setPasscode, sut.viewModel.step.value)
        XCTAssertEqual(error, sut.viewModel.error.value)
    }

    func testForgotPasscodeTappedAskRouterToShowForgotPasscode() {
        // When
        sut.forgotPasscodeTapped()

        // Then
        XCTAssertTrue(router.showForgotPasscodeCalled)
    }

    // MARK: - Helpers

    func givenPasscodeVerified() {
        interactor.nextVerifyCodeResult = .success(true)
        sut.passcodeEntered(passcode)
    }

    func givenNewPasscodeSet() {
        givenPasscodeVerified()
        sut.passcodeEntered(passcode)
    }
}
