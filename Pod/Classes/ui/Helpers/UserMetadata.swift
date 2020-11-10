import Foundation

protocol UserMetadataProtocol {
  func set(_ metadata: String)
  func get() -> String?
  func clear()
}

final class UserMetadata: UserMetadataProtocol {
  static let shared = UserMetadata()

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
