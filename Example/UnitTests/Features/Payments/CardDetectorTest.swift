import XCTest
import AptoSDK

@testable import AptoUISDK

final class CardDetectorTest: XCTestCase {
  
  let cardDetector = CardDetector()
  
  func test_validate_visa_card_type() {
    let detectedCard = cardDetector.detect("4005519200000004", cardNetworks: [CardNetwork.visa])
  
    XCTAssertEqual(detectedCard.cardType, .visa)
    XCTAssertEqual(detectedCard.isValid, true)
  }
  
  func test_not_validate_visa_card_type() {
    let detectedCard = cardDetector.detect("4222222222223", cardNetworks: [CardNetwork.visa])
  
    XCTAssertEqual(detectedCard.isValid, false)
  }
  
  func test_validate_mastercard_card_type() {
    let detectedCard = cardDetector.detect("5555555555554444", cardNetworks: [CardNetwork.mastercard])
  
    XCTAssertEqual(detectedCard.cardType, .mastercard)
    XCTAssertEqual(detectedCard.isValid, true)
  }
  
  func test_not_validate_mastercard_card_type() {
    let detectedCard = cardDetector.detect("5555555555554445", cardNetworks: [CardNetwork.mastercard])
  
    XCTAssertEqual(detectedCard.isValid, false)
  }
  
  func test_validate_amex_card_type() {
    let detectedCard = cardDetector.detect("378282246310005", cardNetworks: [CardNetwork.amex])
  
    XCTAssertEqual(detectedCard.cardType, .amex)
    XCTAssertEqual(detectedCard.isValid, true)
  }
  
  func test_not_validate_amex_card_type() {
    let detectedCard = cardDetector.detect("378282246310006", cardNetworks: [CardNetwork.amex])
  
    XCTAssertEqual(detectedCard.isValid, false)
  }
  
  func test_validate_discover_card_type() {
    let detectedCard = cardDetector.detect("6011111111111117", cardNetworks: [CardNetwork.discover])
  
    XCTAssertEqual(detectedCard.cardType, .discover)
    XCTAssertEqual(detectedCard.isValid, true)
  }
  
  func test_not_validate_discover_card_type() {
    let detectedCard = cardDetector.detect("6011111111111118", cardNetworks: [CardNetwork.discover])
  
    XCTAssertEqual(detectedCard.isValid, false)
  }
}
