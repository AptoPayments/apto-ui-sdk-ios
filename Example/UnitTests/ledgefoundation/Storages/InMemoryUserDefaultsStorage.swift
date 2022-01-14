//
// InMemoryUserDefaultsStorage.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/06/2019.
//

@testable import AptoSDK

class InMemoryUserDefaultsStorage: UserDefaultsStorageProtocol {
    private var cache = [String: Any]()

    func object(forKey key: String) -> Any? {
        return cache[key]
    }

    func set(_ value: Bool, forKey key: String) {
        cache[key] = value
    }

    func removeObject(forKey key: String) {
        cache.removeValue(forKey: key)
    }
}
