import XCTest
import SnapshotTesting
import UIKit

@testable import AptoSDK
@testable import AptoUISDK

final class CreditCardViewTest: XCTestCase {
  
  // Collaborators
  private let dataProvider = ModelDataProvider.provider

  override func setUpWithError() throws {
    AptoPlatform.defaultManager().registerCustomFonts(for: .snapshotTesting)
  }
  
  func test_initial_component_state() {
    assertSnapshot(matching: creditCard(), as: .image)
  }
  
  func test_card_network_visa() {
    // Given
    let card = creditCard()
    card.set(cardNetwork: .visa)

    // Then
    assertSnapshot(matching: card, as: .image)
  }
  
  func test_card_network_mastercard() {
    // Given
    let card = creditCard()
    card.set(cardNetwork: .mastercard)

    // Then
    assertSnapshot(matching: card, as: .image)
  }
  
  func test_card_network_amex() {
    // Given
    let card = creditCard()
    card.set(cardNetwork: .amex)

    // Then
    assertSnapshot(matching: card, as: .image)
  }
  
  func test_update_card_holder_name() {
    // Given
    let card = creditCard()
    card.set(cardHolder: "E Corp")

    // Then
    assertSnapshot(matching: card, as: .image)
  }
  
  func test_update_card_number() {
    // Given
    let card = creditCard()
    card.set(cardNumber: "0000 0000 0000 0000")

    // Then
    assertSnapshot(matching: card, as: .image)
  }
  
  func test_update_card_expiration_data() {
    // Given
    let card = creditCard()
    card.set(expirationMonth: 12, expirationYear: 1964)
    
    // Then
    assertSnapshot(matching: card, as: .image)
  }
 
  func test_hide_card_info() {
    // Given
    let card = creditCard()
    card.set(showInfo: false)
    
    // Then
    assertSnapshot(matching: card, as: .image)
  }
  
  func test_show_last_four_card_digits() {
    // Given
    let card = creditCard()
    card.set(showInfo: false)
    card.set(lastFour: "0123")
    
    // Then
    assertSnapshot(matching: card, as: .image)
  }
  
  func test_started_editing_card() {
    // Given
    let card = creditCard()
    card.didBeginEditingCVC()
    
    // Then
    assertSnapshot(matching: card, as: .image)
  }
}

// MARK: - Helper

extension CreditCardViewTest {
  private static var defaultCardStyle: CardStyle {
    CardStyle(background: .color(color: .white), textColor: "000000", balanceSelectorImage: nil)
  }
  
  fileprivate func creditCard(with cardStyle: CardStyle? = CreditCardViewTest.defaultCardStyle) -> CreditCardView {
    let card = CreditCardView(uiConfiguration: dataProvider.uiConfig, cardStyle: nil)
    card.set(cardStyle: cardStyle)
    card.set(cardHolder: "Apto Test")
    card.set(cardNumber: "0000 1111 2222 3333")
    card.set(expirationMonth: 11, expirationYear: 1992)
    card.set(showInfo: true)
    
    card.snp.makeConstraints { constraint in
      constraint.width.equalTo(300)
      constraint.height.equalTo(card.snp.width).dividedBy(cardAspectRatio)
    }
    return card
  }
}
