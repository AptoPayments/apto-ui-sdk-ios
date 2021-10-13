//
// SetPinModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class SetPinModuleTest: XCTestCase {
  private var sut: SetPinModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let card = ModelDataProvider.provider.card

  override func setUp() {
    super.setUp()
    sut = SetPinModule(serviceLocator: serviceLocator, card: card)
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

  func testInitializeSetUpPresenter() {
    // Given
    let presenter = serviceLocator.presenterLocator.setCodePresenter()

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.analyticsManager)
  }

  func testPinChangeCallClose() {
    // Given
    var finishCalled = false
    sut.onFinish = { _ in
      finishCalled = true
    }

    // When
    sut.codeChanged()

    // Then
    XCTAssertTrue(finishCalled)
  }
}
