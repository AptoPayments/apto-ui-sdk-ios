//
// CardMonthlyStatsModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/01/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class CardMonthlyStatsModuleTest: XCTestCase {
  var sut: CardMonthlyStatsModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let card = ModelDataProvider.provider.card
  private lazy var presenter = serviceLocator.presenterLocatorFake.cardMonthlyStatsPresenterSpy

  override func setUp() {
    super.setUp()

    sut = CardMonthlyStatsModule(serviceLocator: serviceLocator, card: card)
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

  func testShowTransactionsInitializeTransactionListModule() {
    // Given
    let transactionListModule = serviceLocator.moduleLocatorFake.transactionListModuleSpy

    // When
    sut.showTransactions(for: ModelDataProvider.provider.categorySpending, startDate: Date(), endDate: Date())

    // Then
    XCTAssertTrue(transactionListModule.initializeCalled)
  }
}
