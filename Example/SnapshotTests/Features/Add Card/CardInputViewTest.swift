import XCTest
import SnapshotTesting
import SnapKit

@testable import AptoUISDK

final class CardInputViewTest: XCTestCase {
  
  func test_initial_component_state() {
    assertSnapshot(matching: cardInput(), as: .image)
  }
  
  func test_initial_component_state_with_placeholder() {
    assertSnapshot(matching: cardInput(placeholder: "Card number"), as: .image)
  }
  
  func test_visa_card() {
    assertSnapshot(matching: cardInput(with: "4111111111111111"), as: .image)
  }
  
  func test_amex_card() {
    assertSnapshot(matching: cardInput(with: "340000000000009"), as: .image)
  }
  
  func test_discover_card() {
    assertSnapshot(matching: cardInput(with: "6011000000000004"), as: .image)
  }
  
  func test_mastercard_card() {
    assertSnapshot(matching: cardInput(with: "5500000000000004"), as: .image)
  }
  
  
  private func cardInput(with numbers: String? = nil, placeholder: String? = nil) -> CardInputView {
    let cardInputView = CardInputView()
    cardInputView.snp.makeConstraints { constraints in
      constraints.width.equalTo(300)
    }
    
    cardInputView.value = numbers
    cardInputView.placeholder = placeholder
    return cardInputView
  }
}
