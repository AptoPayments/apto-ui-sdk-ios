//
// TransactionListFiltersTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/06/2019.
//

import XCTest
@testable import AptoSDK

class TransactionListFiltersTest: XCTestCase {
  private var sut: TransactionListFilters! // swiftlint:disable:this implicitly_unwrapped_optional

  private lazy var date: Date = {
    let dateComponents = DateComponents(year: 2019, month: 1, day: 17)
    return Calendar(identifier: .gregorian).date(from: dateComponents)! // swiftlint:disable:this force_unwrapping
  }()

  func testEncodePage() {
    // Given
    let sut = TransactionListFilters(page: 1)

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("1", dictionary["page"])
  }

  func testEncodeRows() {
    // Given
    let sut = TransactionListFilters(rows: 20)

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("20", dictionary["rows"])
  }

  func testEncodeLastTransactionId() {
    // Given
    let sut = TransactionListFilters(lastTransactionId: "transaction_id")

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("transaction_id", dictionary["last_transaction_id"])
  }

  func testEncodeStartDate() {
    // Given
    let sut = TransactionListFilters(startDate: date)

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("2019-01-17", dictionary["start_date"])
  }

  func testEncodeEndDate() {
    // Given
    let sut = TransactionListFilters(endDate: date)

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("2019-01-17", dictionary["end_date"])
  }

  func testMCC() {
    // Given
    let sut = TransactionListFilters(mccCode: "mcc")

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("mcc", dictionary["mcc"])
  }

  func testEncodeSingleState() {
    // Given
    let sut = TransactionListFilters(states: [TransactionState.complete])

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("complete", dictionary["state"])
  }

  func testEncodeStates() {
    // Given
    let sut = TransactionListFilters(states: [TransactionState.complete, TransactionState.declined])

    // When
    let dictionary = sut.encoded()

    // Then
    XCTAssertEqual("complete&state=declined", dictionary["state"])
  }
}
