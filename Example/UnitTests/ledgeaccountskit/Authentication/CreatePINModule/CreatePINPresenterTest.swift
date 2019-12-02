//
//  CreatePINPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class CreatePINPresenterTest: XCTestCase {
  private var sut: CreatePINPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = CreatePINModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = CreatePINInteractorFake()
  private let analyticsManager = AnalyticsManagerSpy()
  private let code = "1111"

  override func setUp() {
    super.setUp()

    sut = CreatePINPresenter()
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedTrackEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.createPINStart, analyticsManager.lastEvent)
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
    interactor.nextSaveCodeResult = .success(Void())

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

  func testShowURLCallRouter() {
    // Given
    let url = ModelDataProvider.provider.tappedURL

    // When
    sut.show(url: url)

    // Then
    XCTAssertTrue(router.showURLCalled)
  }
}
