import Foundation

struct CardFormatter {
  
  private let cardDetector: CardDetector
  
  init(cardDetector: CardDetector = .init()) {
    self.cardDetector = cardDetector
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
      
      if idx != 0 && idx % 4 == 0 {
        formattedString.append(" ")
      }
      
      formattedString.append(character)
      idx += 1
    }
    return formattedString
  }
}
