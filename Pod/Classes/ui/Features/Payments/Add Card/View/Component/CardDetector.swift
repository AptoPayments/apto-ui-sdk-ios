import Foundation

enum CardType: Equatable, CaseIterable {
  /* Prefixes and card lengths https://en.wikipedia.org/wiki/Bank_card_number */
  
  case unknown, amex, visa, mastercard, discover
  
  var prefix: [ClosedRange<Int>] {
    switch self {
    case .amex:
      return [34...34, 37...37]
    case .visa:
      return [4...4]
    case .discover:
      return [6011...6011, 65...65, 644...649, 622126...622925]
    case .mastercard:
      return [51...55, 2221...2720]
    default:
      return []
    }
  }
  
  var lenght: [Int] {
    switch self {
    case .amex:
      return [15]
    case .visa:
      return [13, 16, 19]
    case .discover:
      return [16]
    case .mastercard:
      return [16]
    default:
      return []
    }
  }
  
  var grouping: [Int] {
    switch self {
    case .amex:
      return [4, 6, 5]
    default:
      return [4, 4, 4, 4]
    }
  }
}

struct CardDetector {
  
  func detect(_ input: String) -> (cardType: CardType, isValid: Bool) {
    let numbers = input.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: " ", with: "")
    let cardType = self.cardType(for: numbers)
    if cardType != .unknown {
      return (cardType, self.isCardValid(cardType, numbers))
    }
    return (.unknown, false)
  }
  
  private func cardType(for input: String) -> CardType {
    for type in CardType.allCases where type != .unknown {
      for prefix in type.prefix {
        let firstDigits = input.prefix(
          String(prefix.upperBound).count
        )
        if let digits = Int(firstDigits), prefix.contains(digits) {
          return type
        }
      }
    }
    return .unknown
  }
  
  private func isCardValid(_ type: CardType, _ numbers: String) -> Bool {
    type.lenght.contains(numbers.count) && luhnCheck(number: numbers)
  }
  
  /// Shamelessly adapted from https://stackoverflow.com/a/39000648
  private func luhnCheck(number: String) -> Bool {
    var sum = 0
    let reversed = number.reversed().map { String($0) }
    for (index, element) in reversed.enumerated() {
      guard let digit = Int(element) else { return false }
      switch ((index % 2 == 1), digit) {
      case (true, 9): sum += 9
      case (true, 0...8): sum += (digit * 2) % 9
      default: sum += digit
      }
    }
    return sum % 10 == 0
  }
}
