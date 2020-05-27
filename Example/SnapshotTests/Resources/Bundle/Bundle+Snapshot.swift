import Foundation

extension Bundle {
  private final class Snapshot {}
  static let snapshotTesting = Bundle(for: Snapshot.self)
}
