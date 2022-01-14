import XCTest

@testable import AptoUISDK

final class CardFormatterTest: XCTestCase {
    let cardFormater = CardFormatter(cardNetworks: [.amex, .visa, .discover, .mastercard, .other])

    func test_validate_visa_card_type_formatting() {
        let formattedCard = cardFormater.format("4005519200000004")

        XCTAssertEqual(formattedCard, "4005 5192 0000 0004")
    }

    func test_validate_amex_card_type_formatting() {
        let formattedCard = cardFormater.format("378282246310005")

        XCTAssertEqual(formattedCard, "3782 822463 10005")
    }

    func test_validate_mastercard_card_type_formatting() {
        let formattedCard = cardFormater.format("5555555555554444")

        XCTAssertEqual(formattedCard, "5555 5555 5555 4444")
    }

    func test_validate_discover_card_type_formatting() {
        let formattedCard = cardFormater.format("6011111111111117")

        XCTAssertEqual(formattedCard, "6011 1111 1111 1117")
    }

    func test_validate_unknown_card_type_formatting() {
        let formattedCard = cardFormater.format("1212121212121212")

        XCTAssertEqual(formattedCard, "1212 1212 1212 1212")
    }
}
