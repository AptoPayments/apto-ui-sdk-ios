//
// VoIPPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/06/2019.
//

import XCTest
import Bond
import ReactiveKit
import AptoSDK
@testable import AptoUISDK

class VoIPPresenterTest: XCTestCase {
  private var sut: VoIPPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = VoIPModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = VoIPInteractorFake()
  private let analyticsManager = AnalyticsManagerSpy()
  private let voIPCallFake = VoIPCallFake()
  private let disposeBag = DisposeBag()

  override func setUp() {
    super.setUp()
    sut = VoIPPresenter(voIPCaller: voIPCallFake)
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedLogEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.voIPCallStarted, analyticsManager.lastEvent)
  }

  func testViewLoadedFetchVoIPTokens() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.fetchVoIPTokenCalled)
  }

  func testViewLoadedSetViewModelStateToCalling() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(CallState.starting, sut.viewModel.callState.value)
  }

  func testFetchVoIPTokenFailUpdateViewModelErrorProperty() {
    // Given
    interactor.nextFetchVoIPTokenResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertNotNil(sut.viewModel.error.value)
  }

  func testFetchVoIPTokenSucceedStartACall() {
    // Given
    interactor.nextFetchVoIPTokenResult = .success(ModelDataProvider.provider.voIPToken)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(voIPCallFake.callCalled)
  }

  func testStartCallFailUpdateViewModelErrorProperty() {
    // Given
    interactor.nextFetchVoIPTokenResult = .success(ModelDataProvider.provider.voIPToken)
    voIPCallFake.nextCallResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertNotNil(sut.viewModel.error.value)
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.voIPCallFails, analyticsManager.lastEvent)
  }

  func testStartCallSucceedUpdateViewModelState() {
    // Given
    interactor.nextFetchVoIPTokenResult = .success(ModelDataProvider.provider.voIPToken)
    voIPCallFake.nextCallResult = .success(Void())

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(CallState.established, sut.viewModel.callState.value)
    XCTAssertEqual("00:00", sut.viewModel.timeElapsed.value)
  }

  func testMuteCallTappedUpdateCall() {
    // When
    sut.muteCallTapped()

    // Then
    XCTAssertTrue(voIPCallFake.isMuted)
  }

  func testUnmuteCallTappedUpdateCall() {
    //
    sut.muteCallTapped()

    // When
    sut.unmuteCallTapped()

    // Then
    XCTAssertFalse(voIPCallFake.isMuted)
  }

  func testHangupCallTappedDisconnectCall() {
    //
    voIPCallFake.timeElapsed = 45

    // When
    sut.hangupCallTapped()

    // Then
    XCTAssertTrue(voIPCallFake.disconnectCalled)
    XCTAssertEqual(CallState.finished, sut.viewModel.callState.value)
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.voIPCallEnded, analyticsManager.lastEvent)
    XCTAssertEqual(45, analyticsManager.lastProperties?["time_elapsed"] as? Double)
    XCTAssertTrue(router.callFinishedCalled)
  }

  func testTimeElapsedLowerThanAMinuteFormatTimeElapsedAccordingly() {
    // Given
    interactor.nextFetchVoIPTokenResult = .success(ModelDataProvider.provider.voIPToken)
    voIPCallFake.nextCallResult = .success(Void())
    voIPCallFake.timeElapsed = 45
    let expectation = XCTestExpectation(description: "VoIP presenter timer expectation")
    sut.viewModel.timeElapsed.ignoreNils().observeNext { [weak self] timeElapsed in
      guard timeElapsed != "00:00" else { return } // ignore first value
      XCTAssertEqual("00:45", timeElapsed)
      self?.sut.hangupCallTapped()
      expectation.fulfill()
    }.dispose(in: disposeBag)

    // When
    sut.viewLoaded()

    // Then
    wait(for: [expectation], timeout: 2)
  }

  func testTimeElapsedLongerThanAMinuteFormatTimeElapsedAccordingly() {
    // Given
    interactor.nextFetchVoIPTokenResult = .success(ModelDataProvider.provider.voIPToken)
    voIPCallFake.nextCallResult = .success(Void())
    voIPCallFake.timeElapsed = 75
    let expectation = XCTestExpectation(description: "VoIP presenter timer expectation")
    sut.viewModel.timeElapsed.ignoreNils().observeNext { [weak self] timeElapsed in
      guard timeElapsed != "00:00" else { return } // ignore first value
      XCTAssertEqual("01:15", timeElapsed)
      self?.sut.hangupCallTapped()
      expectation.fulfill()
    }.dispose(in: disposeBag)

    // When
    sut.viewLoaded()

    // Then
    wait(for: [expectation], timeout: 2)
  }

  func testKeyboardDigitsTappedSendDigits() {
    // Given
    let digit = "1"

    // When
    sut.keyboardDigitTapped(digit)

    // Then
    XCTAssertTrue(voIPCallFake.sendDigitsCalled)
    XCTAssertEqual(digit, voIPCallFake.lastDigitsSent?.digits)
  }
}
