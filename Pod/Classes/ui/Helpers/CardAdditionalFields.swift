import Foundation

typealias AdditionalFields = [String: AnyObject]

protocol CardAdditionalFieldsProtocol {
    func set(_ additionalFields: AdditionalFields)
    func get() -> AdditionalFields?
}

final class CardAdditionalFields: CardAdditionalFieldsProtocol {
    static let shared = CardAdditionalFields()

    private var additionalFields: AdditionalFields?

    func set(_ additionalFields: AdditionalFields) {
        self.additionalFields = additionalFields
    }

    func get() -> AdditionalFields? {
        additionalFields
    }
}
