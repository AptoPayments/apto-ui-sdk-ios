//
// TransactionDeclineCodeTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 12/07/2019.
//
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class TransactionDeclineCodeTest: XCTestCase {
  func testNilFromReturnsNil() {
    // When
    let sut = TransactionDeclineCode.from(string: nil)

    // Then
    XCTAssertNil(sut)
  }

  func testRandomStringFromReturnsOther() {
    // When
    let sut = TransactionDeclineCode.from(string: "random_string_from_apto")

    // Then
    XCTAssertEqual(TransactionDeclineCode.other, sut)
  }

  func testValidStringFromReturnsExpectedCode() {
    // When
    let sut = TransactionDeclineCode.from(string: "decline_nsf")

    // Then
    XCTAssertEqual(TransactionDeclineCode.nsf, sut)
  }

  func testOtherDescriptionReturnsExpectedString() {
    // Given
    let sut = TransactionDeclineCode.other
    let expectedDescription = "This transaction was declined. Please get in contact with our team if you need assistance."

    // When
    let description = sut.description

    // Then
    XCTAssertEqual(expectedDescription, description)
  }

  func testNonOtherDescriptionReturnsExpectedString() {
    // Given
    let sut = TransactionDeclineCode.nsf
    let expectedDescription = "Insufficient funds"

    // When
    let description = sut.description

    // Then
    XCTAssertEqual(expectedDescription, description)
  }
}
