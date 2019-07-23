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
  private let config = WaitListActionConfiguration(asset: "asset", backgroundImage: "image", backgroundColor: "color")
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()

  override func setUp() {
    super.setUp()

    sut = WaitListPresenter(config: config)
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
    XCTAssertTrue(interactor.reloadApplicationCalled)
  }

  func testReloadApplicationFailsDoNotCallRouter() {
    // Given
    interactor.nextReloadApplicationResult = .failure(BackendError(code: .other))

    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertFalse(router.applicationStatusChangedCalled)
  }

  func testReloadApplicationReturnsWaitListActionDoNotCallRouter() {
    // Given
    interactor.nextReloadApplicationResult = .success(dataProvider.waitListCardApplication)

    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertFalse(router.applicationStatusChangedCalled)
  }

  func testReloadApplicationReturnsNoWaitListActionCallRouter() {
    // Given
    interactor.nextReloadApplicationResult = .success(dataProvider.cardApplication)

    // When
    NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    // Then
    XCTAssertTrue(router.applicationStatusChangedCalled)
  }
  
  func testViewLoadedLogWaitlistEvent() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.workflowWaitlist)
  }
}
