//
// CardStyleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 09/07/2019.
//

@testable import AptoSDK
import SwiftyJSON
import XCTest

class CardStyleTest: XCTestCase {
    // MARK: - Card background style

    func testCardBackgroundStyleWithoutBackgroundCardBackgroundStyleReturnNil() {
        // Given
        let sut = JSON(dictionaryLiteral: ("", ""))

        // When
        let cardBackgroundStyle = sut.cardBackgroundStyle

        // Then
        XCTAssertNil(cardBackgroundStyle)
    }

    func testCardBackgroundImageStyleReturnsAppropriateObject() {
        // Given
        let url = ModelDataProvider.provider.url
        let sut = JSON(dictionaryLiteral: ("background_type", "image"), ("background_image", url.absoluteString))

        // When
        let cardBackgroundStyle = sut.cardBackgroundStyle

        // Then
        XCTAssertEqual(CardBackgroundStyle.image(url: url), cardBackgroundStyle)
    }

    func testCardBackgroundImageStyleWithoutAttributesReturnNil() {
        // Given
        let sut = JSON(dictionaryLiteral: ("background_type", "image"))

        // When
        let cardBackgroundStyle = sut.cardBackgroundStyle

        // Then
        XCTAssertNil(cardBackgroundStyle)
    }

    func testCardBackgroundColorStyleReturnsAppropriateObject() {
        // Given
        let color = UIColor.colorFromHexString("111111")! // swiftlint:disable:this force_unwrapping
        let sut = JSON(dictionaryLiteral: ("background_type", "color"), ("background_color", "111111"))

        // When
        let cardBackgroundStyle = sut.cardBackgroundStyle

        // Then
        XCTAssertEqual(CardBackgroundStyle.color(color: color), cardBackgroundStyle)
    }

    func testCardBackgroundColorStyleWithoutAttributesReturnNil() {
        // Given
        let sut = JSON(dictionaryLiteral: ("background_type", "color"))

        // When
        let cardBackgroundStyle = sut.cardBackgroundStyle

        // Then
        XCTAssertNil(cardBackgroundStyle)
    }

    // MARK: - Card style

    func testCardStyleWithoutBackgroundCardStyleReturnNil() {
        // Given
        let sut = JSON(dictionaryLiteral: ("", ""))

        // When
        let cardStyle = sut.cardStyle

        // Then
        XCTAssertNil(cardStyle)
    }

    func testCardStyleJSONReturnsCardStyle() {
        // Given
        let sut = JSON(parseJSON: """
        {
          "background": {
            "background_type": "color",
            "background_color": "111111"
          },
          "text_color": "FFFFFF",
          "balance_selector_asset": "asset"
        }
        """)

        // When
        let cardStyle = sut.cardStyle

        // Then
        // swiftlint:disable:next force_unwrapping
        XCTAssertEqual(CardBackgroundStyle.color(color: UIColor.colorFromHexString("111111")!), cardStyle?.background)
        XCTAssertEqual("FFFFFF", cardStyle?.textColor)
        XCTAssertEqual("asset", cardStyle?.balanceSelectorImage)
    }
}
