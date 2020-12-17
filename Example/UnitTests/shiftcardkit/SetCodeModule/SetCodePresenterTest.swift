//
// SetPinPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/06/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class SetCodePresenterTest: XCTestCase {
  private var sut: SetCodePresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = SetCodeModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = SetCodeInteractorFake()
  private let analyticsManager = AnalyticsManagerSpy()
  private let pin = "0986"

  override func setUp() {
    super.setUp()
    sut = SetCodePresenter()
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
    sut.codeEntered(pin)

    // Then
    XCTAssertEqual(true, sut.viewModel.showLoading.value)
    XCTAssertTrue(interactor.changeCodeCalled)
    XCTAssertEqual(pin, interactor.lastChangeCodeCode)
  }

  func testPinEnteredTrackEvent() {
    // When
    sut.codeEntered(pin)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.setPinConfirmed, analyticsManager.lastEvent)
  }

  func testChangePinSucceedNotifyRouter() {
    // Given
    interactor.nextChangeCodeResult = .success(ModelDataProvider.provider.card)

    // When
    sut.codeEntered(pin)

    // Then
    XCTAssertEqual(false, sut.viewModel.showLoading.value)
    XCTAssertTrue(router.codeChangedCalled)
  }

  func testChangePinFailShowError() {
    // Given
    let error = BackendError(code: .other)
    interactor.nextChangeCodeResult = .failure(error)

    // When
    sut.codeEntered(pin)

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
