import Foundation

struct TestEnvironment {
  static func isRunningTests() -> Bool {
    return NSClassFromString("XCTest") != nil
  }
}
