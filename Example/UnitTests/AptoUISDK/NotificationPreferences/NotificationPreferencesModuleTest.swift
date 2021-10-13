//
// NotificationPreferencesModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/03/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class NotificationPreferencesModuleTest: XCTestCase {
  private var sut: NotificationPreferencesModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var presenter = serviceLocator.presenterLocatorFake.notificationPreferencesPresenterSpy

  override func setUp() {
    super.setUp()
    sut = NotificationPreferencesModule(serviceLocator: serviceLocator)
  }

  func testInitializeConfigurePresenter() {
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.analyticsManager)
  }

  func testInitializeCallbackSuccess() {
    // Given
    var returnedResult: Result<UIViewController, NSError>?

    // When
    sut.initialize { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }
}
