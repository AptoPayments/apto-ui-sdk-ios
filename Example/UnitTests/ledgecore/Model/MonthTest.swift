//
//  MonthTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 01/10/2019.
//

import XCTest
@testable import AptoSDK

class MonthTest: XCTestCase {
  private let dataProvider = ModelDataProvider.provider

  // MARK: - Init from date
  func testSutProperlyInitializedFromDate() {
    // Given
    // swiftlint:disable:next force_unwrapping
    let date = Calendar.current.date(from: DateComponents(year: 2019, month: 2))!

    // When
    let sut = Month(from: date)

    // Then
    XCTAssertEqual(2019, sut.year)
    XCTAssertEqual(2, sut.month)
  }

  // MARK: - Date methods
  func testFromDateReturnExpectedMonth() {
    // Given
    // swiftlint:disable:next force_unwrapping
    let date = Calendar.current.date(from: DateComponents(year: 2019, month: 2))!

    // When
    let sut = Month(from: date)

    // Then
    let expectedMonth = Month(month: 2, year: 2019)
    XCTAssertEqual(expectedMonth, sut)
  }

  func testToDateReturnExpectedDate() {
    // Given
    let sut = Month(month: 2, year: 2019)

    // When
    let date = sut.toDate()

    // Then
    // swiftlint:disable:next force_unwrapping
    let expectedDate = Calendar.current.date(from: DateComponents(year: 2019, month: 2))!
    XCTAssertEqual(expectedDate, date)
  }

  // MARK: - JSON parser test
  func testMonthIsCreatedFromJSON() {
    // Given
    let sut = dataProvider.monthJSON

    // When
    let month = sut.month

    // Then
    XCTAssertNotNil(month)
  }

  func testMonthIsReturnedFromLinkObject() {
    // Given
    let sut = dataProvider.monthJSON

    // When
    let month = sut.linkObject

    // Then
    XCTAssertNotNil(month)
    XCTAssertTrue(month is Month)
  }

  func testInvalidJSONMonthIsNil() {
    // Given
    let sut = dataProvider.emptyJSON

    // When
    let month = sut.month

    // Then
    XCTAssertNil(month)
  }
}
