//
// SetPinPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/06/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class SetPinPresenterTest: XCTestCase {
  private var sut: SetPinPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = SetPinModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = SetPinInteractorFake()
  private let analyticsManager = AnalyticsManagerSpy()
  private let pin = "0986"

  override func setUp() {
    super.setUp()
    sut = SetPinPresenter()
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedTrackEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.setPin, analyticsManager.lastEvent)
  }

  func testPinEnteredCallInteractor() {
    // When
    sut.pinEntered(pin)

    // Then
    XCTAssertEqual(true, sut.viewModel.showLoading.value)
    XCTAssertTrue(interactor.changePinCalled)
    XCTAssertEqual(pin, interactor.lastPinToChange)
  }

  func testPinEnteredTrackEvent() {
    // When
    sut.pinEntered(pin)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.setPinConfirmed, analyticsManager.lastEvent)
  }

  func testChangePinSucceedNotifyRouter() {
    // Given
    interactor.nextChangePinResult = .success(ModelDataProvider.provider.card)

    // When
    sut.pinEntered(pin)

    // Then
    XCTAssertEqual(false, sut.viewModel.showLoading.value)
    XCTAssertTrue(router.pinChangedCalled)
  }

  func testChangePinFailShowError() {
    // Given
    let error = BackendError(code: .other)
    interactor.nextChangePinResult = .failure(error)

    // When
    sut.pinEntered(pin)

    // Then
    XCTAssertEqual(false, sut.viewModel.showLoading.value)
    XCTAssertNotNil(sut.viewModel.error.value)
  }

  func testCloseTappedCallRouterToClose() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }
}
