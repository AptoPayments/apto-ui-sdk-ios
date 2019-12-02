//
//  CreatePINModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class CreatePINModuleTest: XCTestCase {
  private var sut: CreatePINModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()

  override func setUp() {
    super.setUp()
    sut = CreatePINModule(serviceLocator: serviceLocator)
  }

  func testInitializeCompleteSucceed() {
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
    let presenter = serviceLocator.presenterLocatorFake.createPINPresenter()
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.analyticsManager)
  }
}
