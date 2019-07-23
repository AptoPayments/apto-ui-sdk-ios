//
// AmountTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 05/02/2019.
//

import XCTest
@testable import AptoSDK

class AmountTest: XCTestCase {
  func testSmallAmountTextReturnTwoDecimalFigures() {
    // Given
    let sut = Amount(value: 0.00123, currency: "USD")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("$0.0012", text)
  }

  func testZeroAmountTextReturnTwoDecimalFigures() {
    // Given
    let sut = Amount(value: 0, currency: "BCH")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("BCH 0.00", text)
  }

  func testMinusZeroAmountTextIgnoreSign() {
    // Given
    let sut = Amount(value: -0, currency: "BCH")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("BCH 0.00", text)
  }

  func testNormalAmountTextReturnTwoDecimals() {
    // Given
    let sut = Amount(value: 10.00123, currency: "USD")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("$10.00", text)
  }

  func testGBPCurrencyTextReturnAppropriateCurrency() {
    // Given
    let sut = Amount(value: 10.00123, currency: "GBP")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("£10.00", text)
  }

  func testBitCoinCurrencyTextReturnAppropriateCurrency() {
    // Given
    let sut = Amount(value: 0.000128, currency: "BTC")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("BTC 0.00013", text)
  }

  func testNegativeAmountTextReturnNegativeValue() {
    // Given
    let sut = Amount(value: -10.00123, currency: "USD")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("-$10.00", text)
  }

  func testNegativeAmountAbsTextReturnAbsoluteValue() {
    // Given
    let sut = Amount(value: -10.00123, currency: "USD")

    // When
    let text = sut.absText

    // Then
    XCTAssertEqual("$10.00", text)
  }

  func testCustomCurrencySymbolTextUseCustomSymbol() {
    // Given
    let sut = Amount(value: 10.00123, currency: "MXN")

    // When
    let text = sut.text

    // Then
    XCTAssertEqual("MXN 10.00", text)
  }

  func testAmountExchangeTextReturnExpectedValue() {
    // Given
    let sut = Amount(value: 10.00123, currency: "USD")

    // When
    let exchangeText = sut.exchangeText

    // Then
    XCTAssertEqual("10.00 $", exchangeText)
  }

  func testCustomCurrencyAmountExchangeTextReturnExpectedValue() {
    // Given
    let sut = Amount(value: 10.00123, currency: "MXN")

    // When
    let exchangeText = sut.exchangeText

    // Then
    XCTAssertEqual("10.00 MXN", exchangeText)
  }
}
