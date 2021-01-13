//
//  UserTokenCleanerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 12/1/21.
//

import XCTest
@testable import AptoSDK

class UserTokenCleanerTests: XCTestCase {
    private let userDefaultsStorage = InMemoryUserDefaultsStorage()
    private let keychain = InMemoryKeychain()

    override func setUp() {
        super.setUp()
        userDefaultsStorage.removeObject(forKey: .firstRunKey)
        keychain.removeValue(for: .tokenKey)
    }
    
    func test_firstTimeRun_deliversUserTokenNil() {
        let sut = UserTokenCleaner(localStorage: userDefaultsStorage, keychainStorage: keychain)
        userDefaultsStorage.removeObject(forKey: .firstRunKey)
        
        XCTAssertFalse(sut.hasTokenStored())
    }
    
    func test_firstTimeRun_setsFirstRunKeyTrueToUserDefaults() throws {
        let sut = UserTokenCleaner(localStorage: userDefaultsStorage, keychainStorage: keychain)

        sut.start()
         
        XCTAssertNotNil(userDefaultsStorage.object(forKey: .firstRunKey))
        let firstRunValue = try XCTUnwrap(userDefaultsStorage.object(forKey: .firstRunKey))
        XCTAssertTrue(firstRunValue as! Bool)
    }
    
    func test_firstTimeRun_removeAnyTokenFromKeychainRelatedToPreviousAppInstall() throws {
        let sut = UserTokenCleaner(localStorage: userDefaultsStorage, keychainStorage: keychain)
        userDefaultsStorage.set(true, forKey: .firstRunKey)
        
        sut.start()
        
        XCTAssertNil(keychain.value(for: .tokenKey))
    }

    func test_secondTimeRun_preservesUserToken() {
        let sut = UserTokenCleaner(localStorage: userDefaultsStorage, keychainStorage: keychain)
        let userToken = Data(base64Encoded: "dXNlcl90b2tlbg==")
        userDefaultsStorage.set(true, forKey: .firstRunKey)
        keychain.save(value: userToken, for: .tokenKey)

        sut.start()
        
        XCTAssertNotNil(keychain.value(for: .tokenKey))
        XCTAssertEqual(userToken, keychain.value(for: .tokenKey))
    }
}
