//
// DoubleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 05/02/2019.
//

@testable import AptoSDK
import XCTest

class DoubleTest: XCTestCase {
    private let accuracy = 0.00001

    func testRoundToZeroFiguresReturnRoundedNumber() {
        // Then
        XCTAssertEqual(round(10, toSignificantDecimalFigures: 0), 10.0, accuracy: accuracy)
        XCTAssertEqual(round(10.9, toSignificantDecimalFigures: 0), 11.0, accuracy: accuracy)
        XCTAssertEqual(round(-10.9, toSignificantDecimalFigures: 0), -11.0, accuracy: accuracy)
    }

    func testRoundNumberBiggerThanZeroToTwoFiguresReturnRoundedToTwoDecimalPlaces() {
        // Then
        XCTAssertEqual(round(12.00087, toSignificantDecimalFigures: 2), 12.0, accuracy: accuracy)
        XCTAssertEqual(round(12.0087, toSignificantDecimalFigures: 2), 12.01, accuracy: accuracy)
        XCTAssertEqual(round(-12.0087, toSignificantDecimalFigures: 2), -12.01, accuracy: accuracy)
    }

    func testRoundNumberCloseTwoZeroToTwoFiguresReturnRoundedToTwoDecimalFigures() {
        // Then
        XCTAssertEqual(round(0.000874, toSignificantDecimalFigures: 2), 0.00087, accuracy: accuracy)
        XCTAssertEqual(round(0.000875, toSignificantDecimalFigures: 2), 0.00088, accuracy: accuracy)
        XCTAssertEqual(round(-0.000874, toSignificantDecimalFigures: 2), -0.00087, accuracy: accuracy)
    }
}
