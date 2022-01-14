//
//  CardDetailsTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 10/03/2020.
//

@testable import AptoSDK
import XCTest

class CardDetailsTest: XCTestCase {
    // MARK: - Month

    func testYYdashMMreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "20-03", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testYYslashMMreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "20/03", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testYYdashMMdashDDreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "20-03-01", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testYYslashMMslashDDreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "20/03/01", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testYYYYdashMMreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "2020-03", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testYYYYslashMMreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "2020/03", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testYYYYdashMMdashDDreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "2020-03-01", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testYYYYslashMMslashDDreturnExpectedMonth() {
        // Given
        let sut = CardDetails(expiration: "2020/03/01", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertEqual(3, month)
    }

    func testInvalidSeparatorReturnNilMonth() {
        // Given
        let sut = CardDetails(expiration: "20,03,01", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertNil(month)
    }

    func testInvalidExpirationReturnNilMonth() {
        // Given
        let sut = CardDetails(expiration: "inv/al-id", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertNil(month)
    }

    func testEmptyExpirationReturnNilMonth() {
        // Given
        let sut = CardDetails(expiration: "", pan: "PAN", cvv: "CVV")

        // When
        let month = sut.month

        // Then
        XCTAssertNil(month)
    }

    // MARK: - Year

    func testYYdashMMreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "20-03", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testYYslashMMreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "20/03", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testYYdashMMdashDDreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "20-03-01", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testYYslashMMslashDDreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "20/03/01", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testYYYYdashMMreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "2020-03", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testYYYYslashMMreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "2020/03", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testYYYYdashMMdashDDreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "2020-03-01", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testYYYYslashMMslashDDreturnExpectedYear() {
        // Given
        let sut = CardDetails(expiration: "2020/03/01", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertEqual(20, year)
    }

    func testInvalidSeparatorReturnNilYear() {
        // Given
        let sut = CardDetails(expiration: "20,03,01", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertNil(year)
    }

    func testInvalidExpirationReturnNilYear() {
        // Given
        let sut = CardDetails(expiration: "inv/al-id", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertNil(year)
    }

    func testEmptyExpirationReturnNilYear() {
        // Given
        let sut = CardDetails(expiration: "", pan: "PAN", cvv: "CVV")

        // When
        let year = sut.year

        // Then
        XCTAssertNil(year)
    }
}
