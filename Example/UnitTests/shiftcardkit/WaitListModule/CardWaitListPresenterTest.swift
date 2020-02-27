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
  private let config = WaitListActionConfiguration(asset: "asset", backgroundImage: "image", backgroundColor: "color",
                                                   darkBackgroundColor: "color")
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()
  private let notificationHandler = NotificationHandlerFake()

  override func setUp() {
    super.setUp()

    sut = CardWaitListPresenter(config: config, notificationHandler: notificationHandler)
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
    XCTAssertEqual(config.darkBackgroundColor, sut.viewModel.darkBackgroundColor.value)
  }

  func testViewLoadedObserveApplicationDidBecomeActiveNotification() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(notificationHandler.addObserverCalled)
    XCTAssertTrue(notificationHandler.lastAddObserverObserver === sut)
    XCTAssertEqual(.UIApplicationDidBecomeActive, notificationHandler.lastAddObserverName)
  }

  func testWillEnterForegroundNotificationReceivedRefreshDataFromServer() {
    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
  }

  func testReloadApplicationFailsDoNotCallRouter() {
    // Given
    interactor.nextReloadCardResult = .failure(BackendError(code: .other))

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertFalse(router.cardStatusChangedCalled)
  }

  func testReloadApplicationReturnsWaitListActionDoNotCallRouter() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.waitListedCard)

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertFalse(router.cardStatusChangedCalled)
  }

  func testReloadApplicationReturnsNoWaitListActionCallRouter() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertTrue(router.cardStatusChangedCalled)
    XCTAssertTrue(notificationHandler.removeObserverCalled)
    XCTAssertTrue(notificationHandler.lastRemoveObserverObserver === sut)
  }

  func testViewLoadedLogWaitlistEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.waitlist)
  }
}
