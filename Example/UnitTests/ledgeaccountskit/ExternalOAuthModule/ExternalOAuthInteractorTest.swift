//
//  ExternalOAuthInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class ExternalOAuthInteractorTest: XCTestCase {
  var sut: ExternalOAuthInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var platform = serviceLocator.platformFake
  private lazy var balanceType: AllowedBalanceType = dataProvider.balanceType
  private lazy var oauthAttempt = dataProvider.oauthAttempt
  private lazy var presenter = serviceLocator.presenterLocatorFake.externalOauthPresenterSpy

  override func setUp() {
    super.setUp()

    sut = ExternalOAuthInteractor(platform: platform)
    sut.presenter = presenter
  }

  func testCustodianSelectedStartOauthAuthentication() {
    // When
    sut.balanceTypeSelected(balanceType)

    // Then
    XCTAssertTrue(platform.startOauthAuthenticationCalled)
  }

  func testStartOauthAuthenticationFailShowError() {
    // Given
    platform.nextStartOauthAuthenticationResult = .failure(BackendError(code: .other))

    // When
    sut.balanceTypeSelected(balanceType)

    // Then
    XCTAssertTrue(presenter.showErrorCalled)
    XCTAssertNotNil(presenter.lastErrorShown)
  }

  func testStartOauthAuthenticationSucceedShowUrl() {
    // Given
    platform.nextStartOauthAuthenticationResult = .success(oauthAttempt)

    // When
    sut.balanceTypeSelected(balanceType)

    // Then
    XCTAssertTrue(presenter.showUrlCalled)
    XCTAssertNotNil(presenter.lastUrlShown)
  }

  func testStartOauthAuthenticationSucceedCustodianUrlOpenedCallVerifyOauthAttemptStatus() {
    // Given
    givenStartOauthAuthenticationSucceed()

    // When
    sut.verifyOauthAttemptStatus { _ in }

    // Then
    XCTAssertTrue(platform.verifyOauthAttemptStatusCalled)
  }

  func testVerifyOauthAttemptFailShowError() {
    // Given
    givenStartOauthAuthenticationSucceed()
    platform.nextVerifyOauthAttemptStatusResult = .failure(BackendError(code: .other))

    // When
    sut.verifyOauthAttemptStatus { result in
      // Then
      XCTAssertEqual(Result<OauthAttempt, NSError>.failure(BackendError(code: .other)), result)
    }
  }

  func testVerifyOauthAttemptSucceedCallCustodianSelected() {
    // Given
    givenStartOauthAuthenticationSucceed()
    platform.nextVerifyOauthAttemptStatusResult = .success(dataProvider.oauthAttempt)

    // When
    sut.verifyOauthAttemptStatus { result in
      // Then
      XCTAssertTrue(result.isSuccess)
    }
  }

  private func givenStartOauthAuthenticationSucceed() {
    platform.nextStartOauthAuthenticationResult = .success(oauthAttempt)
    sut.balanceTypeSelected(balanceType)
  }
}
