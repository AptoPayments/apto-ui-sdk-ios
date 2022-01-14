//
//  LocalCacheFileManager.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 25/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import AptoSDK
import Foundation

class LocalCacheFileManagerSpy: LocalCacheFileManagerProtocol {
    var cache = [String: Data]()

    func write(data: Data, filename: String) throws {
        cache[filename] = data
    }

    func read(filename: String) throws -> Data? {
        cache[filename]
    }

    func invalidate() throws {
        cache.removeAll()
    }
}
