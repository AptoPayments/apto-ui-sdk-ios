//
// CardWaitListPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class CardWaitListPresenterTest: XCTestCase {
  private var sut: CardWaitListPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = CardWaitListModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = CardWaitListInteractorFake()
  private let dataProvider = ModelDataProvider.provider
  private let config = WaitListActionConfiguration(asset: "asset", backgroundImage: "image", backgroundColor: "color")
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()

  override func setUp() {
    super.setUp()

    sut = CardWaitListPresenter(config: config)
    sut.interactor = interactor
    sut.router = router
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedUpdateViewModel() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(config.asset, sut.viewModel.asset.value)
    XCTAssertEqual(config.backgroundImage, sut.viewModel.backgroundImage.value)
    XCTAssertEqual(config.backgroundColor, sut.viewModel.backgroundColor.value)
  }

  func testWillEnterForegroundNotificationReceivedRefreshDataFromServer() {
    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
  }

  func testReloadApplicationFailsDoNotCallRouter() {
    // Given
    interactor.nextReloadCardResult = .failure(BackendError(code: .other))

    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertFalse(router.cardStatusChangedCalled)
  }

  func testReloadApplicationReturnsWaitListActionDoNotCallRouter() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.waitListedCard)

    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertFalse(router.cardStatusChangedCalled)
  }

  func testReloadApplicationReturnsNoWaitListActionCallRouter() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)

    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertTrue(router.cardStatusChangedCalled)
  }

  func testViewLoadedLogWaitlistEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.waitlist)
  }
}
