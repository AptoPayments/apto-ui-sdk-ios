//
//  InMemoryKeychain.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/03/2020.
//

@testable import AptoSDK

class InMemoryKeychain: KeychainProtocol {
  var cache = [String: Data?]()

  @discardableResult
  func save(value: Data?, for key: String) -> Bool {
    cache[key] = value
    return true
  }

  func value(for key: String) -> Data? {
    return cache[key] ?? nil
  }

  @discardableResult
  func removeValue(for key: String) -> Bool {
    cache[key] = nil
    return true
  }
}
