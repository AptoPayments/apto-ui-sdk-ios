//
// WaitListPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 27/02/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class WaitListPresenterTest: XCTestCase {
  private var sut: WaitListPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = WaitListModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = WaitListInteractorFake()
  private let dataProvider = ModelDataProvider.provider
  private let config = WaitListActionConfiguration(asset: "asset", backgroundImage: "image", backgroundColor: "color",
                                                   darkBackgroundColor: "color")
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()
  private let notificationHandler = NotificationHandlerFake()

  override func setUp() {
    super.setUp()

    sut = WaitListPresenter(config: config, notificationHandler: notificationHandler)
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
    XCTAssertTrue(interactor.reloadApplicationCalled)
  }

  func testReloadApplicationFailsDoNotCallRouter() {
    // Given
    interactor.nextReloadApplicationResult = .failure(BackendError(code: .other))

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertFalse(router.applicationStatusChangedCalled)
  }

  func testReloadApplicationReturnsWaitListActionDoNotCallRouter() {
    // Given
    interactor.nextReloadApplicationResult = .success(dataProvider.waitListCardApplication)

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertFalse(router.applicationStatusChangedCalled)
  }

  func testReloadApplicationReturnsNoWaitListActionCallRouter() {
    // Given
    interactor.nextReloadApplicationResult = .success(dataProvider.cardApplication)

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertTrue(router.applicationStatusChangedCalled)
    XCTAssertTrue(notificationHandler.removeObserverCalled)
    XCTAssertTrue(notificationHandler.lastRemoveObserverObserver === sut)
  }

  func testViewLoadedLogWaitlistEvent() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.workflowWaitlist)
  }
}
