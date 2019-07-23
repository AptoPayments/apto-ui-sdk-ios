//
// TransactionListInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/01/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class TransactionListInteractorTest: XCTestCase {
  var sut: TransactionListInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let card = ModelDataProvider.provider.card
  private lazy var platform = ServiceLocatorFake().platformFake
  private let dataProvider = ModelDataProvider.provider
  private let filters = TransactionListFilters()

  override func setUp() {
    super.setUp()

    sut = TransactionListInteractor(card: card, platform: platform)
  }

  func testFetchTransactionsCallCardSession() {
    // When
    sut.fetchTransactions(filters: filters) { _ in }

    // Then
    XCTAssertTrue(platform.fetchCardTransactionsCalled)
  }

  func testFetchingTransactionsSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<[Transaction], NSError>?
    platform.nextFetchCardTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.fetchTransactions(filters: filters) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testFetchingTransactionsFailsCallbackFailure() {
    // Given
    var returnedResult: Result<[Transaction], NSError>?
    platform.nextFetchCardTransactionsResult = .failure(BackendError(code: .other))

    // When
    sut.fetchTransactions(filters: filters) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
}
