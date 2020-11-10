import Foundation

protocol CardMetadataProtocol {
  func set(_ metadata: String)
  func get() -> String?
  func clear()
}

final class CardMetadata: CardMetadataProtocol {
  static let shared = CardMetadata()

  private var metadata: String? = nil

  func set(_ metadata: String) {
    self.metadata = metadata
  }

  func get() -> String? {
    metadata
  }

  func clear() {
    metadata = nil
  }
}
