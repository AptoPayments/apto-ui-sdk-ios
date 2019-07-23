//
// TransactionListModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/01/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class TransactionListModuleTest: XCTestCase {
  var sut: TransactionListModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let card = ModelDataProvider.provider.card
  private let config = TransactionListModuleConfig(startDate: Date(),
                                                   endDate: Date(),
                                                   categoryId: MCCIcon.plane)
  private lazy var presenter = serviceLocator.presenterLocatorFake.transactionListPresenterSpy

  override func setUp() {
    super.setUp()

    sut = TransactionListModule(serviceLocator: serviceLocator, card: card, config: config)
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

  func testInitializeConfigurePresenter() {
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.analyticsManager)
  }
}
