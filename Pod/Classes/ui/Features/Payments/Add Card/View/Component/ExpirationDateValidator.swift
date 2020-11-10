import Foundation

struct ExpirationDateValidator {

  private static let currentMillenium = 2000
  
  func validate(_ input: String) -> Bool {
    guard let (month, year) = self.extractDate(from: input) else { return false }

    guard month > 0 && month <= 12 else { return false }
    guard ExpirationDateValidator.currentMillenium + year >= Date().year else { return false }
    return true
  }
  
  func extractDate(from input: String) -> (month: Int, year: Int)? {
    let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let splittedComponents = trimmedInput.split(separator: "/")
    
    guard splittedComponents.count == 2,
      let month = Int(splittedComponents[0]),
      var year = Int(splittedComponents[1]) else { return nil }

    if year < ExpirationDateValidator.currentMillenium {
      year = year + ExpirationDateValidator.currentMillenium
    }

    return (month, year)
  }
}
