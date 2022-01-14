//
//  MonthlyStatementReportTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 20/09/2019.
//

@testable import AptoSDK
import SwiftyJSON
import XCTest

class MonthlyStatementReportTest: XCTestCase {
    private let dataProvider = ModelDataProvider.provider

    // MARK: - JSON Parser test

    func testMonthlyStatementReportIsCreatedFromJSON() {
        // Given
        let sut = dataProvider.monthlyStatementReportJSON

        // When
        let statementReport = sut.monthlyStatementReport

        // Then
        XCTAssertNotNil(statementReport?.id)
        XCTAssertNotNil(statementReport?.month)
        XCTAssertNotNil(statementReport?.year)
        XCTAssertNotNil(statementReport?.downloadUrl)
        XCTAssertNotNil(statementReport?.urlExpirationDate)
    }

    func testMonthlyStatementReportIsReturnedFromLinkObject() {
        // Given
        let sut = dataProvider.monthlyStatementReportJSON

        // When
        let statementReport = sut.linkObject

        // Then
        XCTAssertNotNil(statementReport)
        XCTAssertTrue(statementReport is MonthlyStatementReport)
    }

    func testMonthlyStatementReportWithInvalidJSONReturnNil() {
        // Given
        let sut = dataProvider.emptyJSON

        // When
        let statementReport = sut.monthlyStatementReport

        // Then
        XCTAssertNil(statementReport)
    }

    func testMonthlyStatementReportWithoutIdReturnNil() {
        // Given
        var sut = dataProvider.monthlyStatementReportJSON
        try! sut.merge(with: JSON(dictionaryLiteral: ("id", NSNull())))

        // When
        let statementReport = sut.monthlyStatementReport

        // Then
        XCTAssertNil(statementReport)
    }

    func testMonthlyStatementReportWithoutMonthReturnNil() {
        // Given
        var sut = dataProvider.monthlyStatementReportJSON
        try! sut.merge(with: JSON(dictionaryLiteral: ("month", NSNull())))

        // When
        let statementReport = sut.monthlyStatementReport

        // Then
        XCTAssertNil(statementReport)
    }

    func testMonthlyStatementReportWithoutYearReturnNil() {
        // Given
        var sut = dataProvider.monthlyStatementReportJSON
        try! sut.merge(with: JSON(dictionaryLiteral: ("year", NSNull())))

        // When
        let statementReport = sut.monthlyStatementReport

        // Then
        XCTAssertNil(statementReport)
    }
}
