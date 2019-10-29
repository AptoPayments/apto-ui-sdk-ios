//
//  ExternalOAuthPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class ExternalOAuthPresenterTest: XCTestCase {
  private var sut: ExternalOAuthPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private lazy var dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var balanceType: AllowedBalanceType = dataProvider.balanceType
  private let url = URL(string: "https://shitfpayments.com")! // swiftlint:disable:this force_unwrapping
  private let interactor = ExternalOAuthInteractorFake()
  private let router = ExternalOAuthModuleFake(serviceLocator: ServiceLocatorFake())
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()

  override func setUp() {
    super.setUp()

    sut = ExternalOAuthPresenter(config: dataProvider.externalOauthModuleConfig)
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedUpdateViewModel() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertNotNil(sut.viewModel.title.value)
    XCTAssertNotNil(sut.viewModel.explanation.value)
    XCTAssertNotNil(sut.viewModel.callToAction.value)
    XCTAssertNotNil(sut.viewModel.newUserAction.value)
    XCTAssertNotNil(sut.viewModel.allowedBalanceTypes.value)
    XCTAssertNotNil(sut.viewModel.assetUrl)
    XCTAssertNil(sut.viewModel.error.value)
  }

  func testCustodianTappedCallInteractor() {
    // When
    sut.balanceTypeTapped(balanceType)

    // Then
    XCTAssertTrue(interactor.balanceTypeSelectedCalled)
  }

  func testBackTappedCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.backInExternalOAuthCalled)
  }

  func testOauthInteractorGenericErrorDoesntCallRouter() {
    // Given
    interactor.nextVerifyOauthAttemptStatusResult = .failure(NSError())

    // When
    sut.show(url: url)

    // Then
    XCTAssertFalse(router.oauthSucceededCalled)
    XCTAssertNil(router.lastOauthCustodian)
  }

  func testOauthErrorDoesntCallRouter() {
    // Given
    interactor.nextVerifyOauthAttemptStatusResult = .success(dataProvider.oauthErrorAttempt)

    // When
    sut.show(url: url)

    // Then
    XCTAssertFalse(router.oauthSucceededCalled)
    XCTAssertNil(router.lastOauthCustodian)
  }

  func testOauthSuccessCallRouter() {
    // Given
    sut.balanceTypeTapped(dataProvider.balanceType)
    interactor.nextVerifyOauthAttemptStatusResult = .success(dataProvider.oauthAttempt)

    // When
    sut.show(url: url)

    // Then
    XCTAssertTrue(router.oauthSucceededCalled)
    XCTAssertNotNil(router.lastOauthCustodian)
  }

  func testShowUrlCallRouter() {
    // When
    sut.show(url: url)

    // Then
    XCTAssertTrue(router.showUrlCalled)
    XCTAssertNotNil(router.lastUrlShown)
  }

  func testShowUrlRouterCallbackCalledShowLoadingViewAndCallInteractor() {
    // When
    sut.show(url: url)

    // Then
    XCTAssertTrue(router.showLoadingViewCalled)
    XCTAssertTrue(interactor.verifyOauthAttemptStatus)
  }

  func testNewUserCalledCallRouter() {
    // When
    sut.newUserTapped(url: url)

    // Then
    XCTAssertTrue(router.showUrlCalled)
    XCTAssertEqual(url, router.lastUrlShown)
  }

  func testViewLoadedLogSelectBalanceStoreLoginEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreLogin)
  }

  func testOnBalanceTappedLogselectBalanceStoreLoginConnect() {
    // When
    sut.balanceTypeTapped(balanceType)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreLoginConnectTap)
  }
}
