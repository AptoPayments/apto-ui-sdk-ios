//
//  FullScreenDisclaimerPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 09/06/2018.
//
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class FullScreenDisclaimerPresenterTest: XCTestCase {
  private var sut: FullScreenDisclaimerPresenter!

  // Collaborators
  private lazy var router = FullScreenDisclaimerRouterSpy()
  private lazy var interactor = FullScreenDisclaimerInteractorFake()
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()

  override func setUp() {
    super.setUp()

    sut = FullScreenDisclaimerPresenter()
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedCalledAskInteractorToProvideDisclaimer() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideDisclaimerCalled)
  }

  func testViewLoadedCalledSetViewDisclaimer() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(interactor.disclaimer, sut.viewModel.disclaimer.value)
  }

  func testCloseTappedAskRouterToClose() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }

  func testAgreeTappedNotifyRouter() {
    // When
    sut.agreeTapped()

    // Then
    XCTAssertTrue(router.agreeTappedCalled)
  }

  func testLinkTappedCallShowExternalURL() {
    // Given
    let url = URL(string: "https://shiftpayments.com")!

    // When
    sut.linkTapped(url)

    // Then
    XCTAssertTrue(router.showExternalCalled)
    XCTAssertEqual(url, router.lastURL!) // swiftlint:disable:this implicitly_unwrapped_optional
  }

  func testViewLoadedLogDisclaimerEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.disclaimer)
  }
}
