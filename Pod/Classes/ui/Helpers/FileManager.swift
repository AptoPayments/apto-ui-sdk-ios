//
//  FileManager.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

import Foundation

protocol FileManagerProtocol {
  func save(data: Data) throws
  func read() throws -> Data?
  func delete() throws
}

class FileManagerImpl: FileManagerProtocol {
  private let filename: String

  init(filename: String) {
    self.filename = filename
  }

  func save(data: Data) throws {
    try data.write(to: fileURL(), options: [.atomic, .completeFileProtection])
  }

  func read() throws -> Data? {
    return try Data(contentsOf: fileURL())
  }

  func delete() throws {
    try FileManager.default.removeItem(at: fileURL())
  }

  private func fileURL() throws -> URL {
    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                        appropriateFor: nil, create: true)
    let sdkNamespace = "com.aptopayments.sdk"
    let directory = documentDirectory.appendingPathComponent(sdkNamespace)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    return directory.appendingPathComponent(filename)
  }
}
