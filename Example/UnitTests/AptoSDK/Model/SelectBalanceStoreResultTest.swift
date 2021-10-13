//
//  SelectBalanceStoreResultTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 13/08/2019.
//

import XCTest
@testable import AptoSDK

class SelectBalanceStoreResultTest: XCTestCase {
  func testValidResultIsSuccessReturnTrue() {
    // Given
    let sut = SelectBalanceStoreResult(result: .valid, errorCode: nil)

    // When
    let isSuccess = sut.isSuccess

    // Then
    XCTAssertTrue(isSuccess)
  }

  func testValidResultIsErrorReturnFalse() {
    // Given
    let sut = SelectBalanceStoreResult(result: .valid, errorCode: nil)

    // When
    let isError = sut.isError

    // Then
    XCTAssertFalse(isError)
  }

  func testValidResultErrorMessageIsEmptyString() {
    // Given
    let sut = SelectBalanceStoreResult(result: .valid, errorCode: nil)

    // When
    let errorMessage = sut.errorMessage

    // Then
    XCTAssertTrue(errorMessage.isEmpty)
  }

  func testInvalidResultIsSuccessReturnFalse() {
    // Given
    let sut = SelectBalanceStoreResult(result: .invalid, errorCode: 90191)

    // When
    let isSuccess = sut.isSuccess

    // Then
    XCTAssertFalse(isSuccess)
  }

  func testInvalidResultIsErrorReturnTrue() {
    // Given
    let sut = SelectBalanceStoreResult(result: .invalid, errorCode: 90191)

    // When
    let isError = sut.isError

    // Then
    XCTAssertTrue(isError)
  }

  func testInvalidResultErrorMessageReturnMessage() {
    // Given
    let sut = SelectBalanceStoreResult(result: .invalid, errorCode: 90191)

    // When
    let errorMessage = sut.errorMessage

    // Then
    XCTAssertFalse(errorMessage.isEmpty)
  }

  func testCustomErrorMessageKeysErrorMessageReturnCustomMessage() {
    // Given
    let customKey = "custom.login.error_wrong_country.message"
    let sut = SelectBalanceStoreResult(result: .invalid, errorCode: 90191, errorMessageKeys: [customKey])

    // When
    let errorMessage = sut.errorMessage

    // Then
    XCTAssertEqual(customKey, errorMessage)
  }
}
