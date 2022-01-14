//
//  MonthlyStatementsPeriodTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 01/10/2019.
//

@testable import AptoSDK
import XCTest

class MonthlyStatementsPeriodTest: XCTestCase {
    private let dataProvider = ModelDataProvider.provider

    // MARK: - Available months

    func testAvailableMonthsReturnStartToEnd() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriod

        // When
        let availableMonths = sut.availableMonths()

        // Then
        let expectedMonths = [5, 6, 7, 8, 9].map { Month(month: $0, year: 2019) }
        XCTAssertEqual(expectedMonths, availableMonths)
    }

    func testAvailableMonthsChangingYearReturnStartToEnd() {
        // Given
        let sut = MonthlyStatementsPeriod(start: Month(month: 11, year: 2018), end: Month(month: 2, year: 2019))

        // When
        let availableMonths = sut.availableMonths()

        // Then
        let expectedMonths = [(11, 2018), (12, 2018), (1, 2019), (2, 2019)].map { Month(month: $0.0, year: $0.1) }
        XCTAssertEqual(expectedMonths, availableMonths)
    }

    func testStartOlderThanEndReturnEmptyList() {
        // Given
        let sut = MonthlyStatementsPeriod(start: Month(month: 3, year: 2019), end: Month(month: 2, year: 2019))

        // When
        let availableMonths = sut.availableMonths()

        // Then
        XCTAssertTrue(availableMonths.isEmpty)
    }

    func testStartEqualToEndReturnSingleElementList() {
        // Given
        let sut = MonthlyStatementsPeriod(start: dataProvider.month, end: dataProvider.month)

        // When
        let availableMonths = sut.availableMonths()

        // Then
        let expectedMonths = [dataProvider.month]
        XCTAssertEqual(expectedMonths, availableMonths)
    }

    // MARK: - is date valid

    func testStartSameMonthAsStartIsValidReturnTrue() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriod

        // When
        let isValid = sut.includes(month: sut.start)

        // Then
        XCTAssertTrue(isValid)
    }

    func testStartSameMonthAsEndIsValidReturnTrue() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriod

        // When
        let isValid = sut.includes(month: sut.end)

        // Then
        XCTAssertTrue(isValid)
    }

    func testMonthBetweenStartAndEndIsValidReturnTrue() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriod

        // When
        let isValid = sut.includes(month: Month(month: sut.start.month + 1, year: sut.start.year))

        // Then
        XCTAssertTrue(isValid)
    }

    func testMonthBeforeStartIsValidReturnFalse() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriod

        // When
        let isValid = sut.includes(month: Month(month: sut.start.month - 1, year: sut.start.year))

        // Then
        XCTAssertFalse(isValid)
    }

    func testMonthAfterEndIsValidReturnFalse() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriod

        // When
        let isValid = sut.includes(month: Month(month: sut.end.month + 1, year: sut.end.year))

        // Then
        XCTAssertFalse(isValid)
    }

    // MARK: - JSON parser test

    func testMonthIsCreatedFromJSON() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriodJSON

        // When
        let monthlyStatementsPeriod = sut.monthlyStatementsPeriod

        // Then
        XCTAssertNotNil(monthlyStatementsPeriod)
    }

    func testMonthIsReturnedFromLinkObject() {
        // Given
        let sut = dataProvider.monthlyStatementsPeriodJSON

        // When
        let monthlyStatementsPeriod = sut.linkObject

        // Then
        XCTAssertNotNil(monthlyStatementsPeriod)
        XCTAssertTrue(monthlyStatementsPeriod is MonthlyStatementsPeriod)
    }

    func testInvalidJSONMonthIsNil() {
        // Given
        let sut = dataProvider.emptyJSON

        // When
        let monthlyStatementsPeriod = sut.monthlyStatementsPeriod

        // Then
        XCTAssertNil(monthlyStatementsPeriod)
    }
}
