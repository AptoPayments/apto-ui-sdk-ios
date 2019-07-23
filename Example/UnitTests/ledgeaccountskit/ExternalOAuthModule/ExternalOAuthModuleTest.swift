//
//  ExternalOAuthModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class ExternalOAuthModuleTest: XCTestCase {
  private var sut: ExternalOAuthModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var dataProvider: ModelDataProvider = ModelDataProvider.provider
  private lazy var config = dataProvider.externalOauthModuleConfig
  private lazy var uiConfig = dataProvider.uiConfig

  override func setUp() {
    super.setUp()

    sut = ExternalOAuthModule(serviceLocator: serviceLocator, config: config, uiConfig: uiConfig)
  }

  func testInitializeConfigurePresenter() {
    // Given
    let presenter = serviceLocator.presenterLocatorFake.externalOauthPresenterSpy

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.analyticsManager)
  }

  func testInitializeConfigureInteractor() {
    // Given
    let interactor = serviceLocator.interactorLocatorFake.externalOauthInteractorSpy

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(interactor.presenter)
  }

  func testBackInExternalOauthCallClosure() {
    // Given
    var onCloseCalled = false
    sut.onClose = { _ in
      onCloseCalled = true
    }

    // When
    sut.backInExternalOAuth(false)

    // Then
    XCTAssertTrue(onCloseCalled)
  }

  func testOauthSucceededCallClosure() {
    // Given
    var onAuthSucceededCalled = false
    sut.onOAuthSucceeded = { _, _ in
      onAuthSucceededCalled = true
    }

    // When
    sut.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(onAuthSucceededCalled)
  }
}
