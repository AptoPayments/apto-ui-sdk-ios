import AptoSDK
import Foundation

enum CardType: String, Equatable, CaseIterable {
    /* Prefixes and card lengths https://en.wikipedia.org/wiki/Bank_card_number */

    case unknown, amex, visa, mastercard, discover

    var prefix: [ClosedRange<Int>] {
        switch self {
        case .amex:
            return [34 ... 34, 37 ... 37]
        case .visa:
            return [4 ... 4]
        case .discover:
            return [6011 ... 6011, 65 ... 65, 644 ... 649, 622_126 ... 622_925]
        case .mastercard:
            return [51 ... 55, 2221 ... 2720]
        default:
            return []
        }
    }

    // swiftlint:disable line_length
    var regex: String {
        switch self {
        case .amex:
            return "^3[47][0-9]{13}$"
        case .visa:
            return "^4[0-9]{15}$"
        case .discover:
            return "^6(?:011\\d{12}|5\\d{14}|4[4-9]\\d{13}|22(?:1(?:2[6-9]|[3-9]\\d)|[2-8]\\d{2}|9(?:[01]\\d|2[0-5]))\\d{10})$"
        case .mastercard:
            return "^(?:5[1-5]|2(?!2([01]|20)|7(2[1-9]|3))[2-7])\\d{14}$"
        default:
            return ""
        }
    }

    // swiftlint:enable line_length

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
    func detect(_ input: String, cardNetworks: [CardNetwork] = []) -> (cardType: CardType, isValid: Bool) {
        let numbers = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        let cardType = self.cardType(for: numbers, cardNetworks: cardNetworks)
        if cardType != .unknown {
            return (cardType, isCardValid(cardType, numbers))
        }
        return (.unknown, false)
    }

    private func cardType(for input: String, cardNetworks: [CardNetwork]) -> CardType {
        for type in CardType.allCases where
            type != .unknown && cardNetworks.map({ $0.rawValue }).contains(type.rawValue)
        {
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
        type.lenght.contains(numbers.count) && luhnCheck(number: numbers) && matchesRegex(regex: type.regex, text: numbers)
    }

    // swiftlint:disable implicitly_unwrapped_optional legacy_constructor
    private func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, text.count))
            return match != nil
        } catch {
            return false
        }
    }

    // swiftlint:enable implicitly_unwrapped_optional legacy_constructor

    /// Shamelessly adapted from https://stackoverflow.com/a/39000648
    private func luhnCheck(number: String) -> Bool {
        var sum = 0
        let reversed = number.reversed().map { String($0) }
        for (index, element) in reversed.enumerated() {
            guard let digit = Int(element) else { return false }
            switch (index % 2 == 1, digit) {
            case (true, 9): sum += 9
            case (true, 0 ... 8): sum += (digit * 2) % 9
            default: sum += digit
            }
        }
        return sum % 10 == 0
    }
}
