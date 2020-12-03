import Foundation
import AptoSDK

struct CardFormatter {
  
  private let cardDetector: CardDetector
  private let cardNetworks: [CardNetwork]
  
  init(cardDetector: CardDetector = .init(), cardNetworks: [CardNetwork]) {
    self.cardDetector = cardDetector
    self.cardNetworks = cardNetworks
  }
  
  func format(_ input: String) -> String {
    let normalizedString = input.replacingOccurrences(of: " ", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
 
    var formattedString = ""
    var idx = 0
    var character: Character
    
    while idx < normalizedString.count {
      let index = normalizedString.index(normalizedString.startIndex, offsetBy: idx)
      character = normalizedString[index]
        switch cardDetector.detect(input, cardNetworks: cardNetworks) {
        case (.amex, _):
            if idx == 4 || idx == 10 {
                formattedString.append(" ")
            }
        default:
            if idx != 0 && idx % 4 == 0 {
              formattedString.append(" ")
            }
        }

      
      formattedString.append(character)
      idx += 1
    }
    return formattedString
  }
}
