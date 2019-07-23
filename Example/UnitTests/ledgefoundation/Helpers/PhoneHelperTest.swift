//
// PhoneHelperTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/04/2019.
//

import XCTest
@testable import AptoSDK

class PhoneHelperTest: XCTestCase {
  private let sut = PhoneHelper.sharedHelper()

  func testUSPhoneNumberValidatePhoneReturnTrue() {
    // Given
    let countryCode = 1
    let number = "2342303796"

    // When
    let isValid = sut.validatePhoneWith(countryCode: countryCode, nationalNumber: number)

    // Then
    XCTAssertTrue(isValid)
  }

  func testPartialUSPhoneNumberValidatePhoneReturnFalse() {
    // Given
    let countryCode = 1
    let number = "234230"

    // When
    let isValid = sut.validatePhoneWith(countryCode: countryCode, nationalNumber: number)

    // Then
    XCTAssertFalse(isValid)
  }

  func testUSPhoneNumberWithUKCountryCodeValidatePhoneReturnFalse() {
    // Given
    let countryCode = 44
    let number = "2342303796"

    // When
    let isValid = sut.validatePhoneWith(countryCode: countryCode, nationalNumber: number)

    // Then
    XCTAssertFalse(isValid)
  }

  func testPhoneNumberAssumeUSByDefault() {
    // Given
    let number = "2342303796"

    // When
    let isValid = sut.validatePhoneWith(nationalNumber: number)

    // Then
    XCTAssertTrue(isValid)
  }

  func testPhoneNumberWithSameCountryValidatePhoneReturnTrue() {
    // Given
    let countryCode = 1
    let number = "+12342303796"

    // When
    let isValid = sut.validatePhoneWith(countryCode: countryCode, nationalNumber: number)

    // Then
    XCTAssertTrue(isValid)
  }

  func testPhoneNumberWithDifferentCountryValidatePhoneReturnFalse() {
    // Given
    let countryCode = 1
    let number = "+442342303796"

    // When
    let isValid = sut.validatePhoneWith(countryCode: countryCode, nationalNumber: number)

    // Then
    XCTAssertFalse(isValid)
  }
}
