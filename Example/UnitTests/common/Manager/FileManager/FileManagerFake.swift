//
//  FileManagerFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

@testable import AptoUISDK

class FileManagerFake: FileManagerProtocol {
  var shouldThrow = false

  private(set) var saveCalled = false
  private(set) var lastSaveData: Data?
  func save(data: Data) throws {
    saveCalled = true
    lastSaveData = data
    if shouldThrow {
      throw NSError(domain: "com.aptopayments.sdk.error.save_file", code: 1001, userInfo: nil)
    }
  }

  private(set) var readCalled = false
  var nextReadResult: Data?
  func read() throws -> Data? {
    readCalled = true
    if shouldThrow {
      throw NSError(domain: "com.aptopayments.sdk.error.save_file", code: 1001, userInfo: nil)
    }
    return nextReadResult
  }

  private(set) var deleteCalled = false
  func delete() throws {
    deleteCalled = true
    if shouldThrow {
      throw NSError(domain: "com.aptopayments.sdk.error.save_file", code: 1001, userInfo: nil)
    }
  }
}
