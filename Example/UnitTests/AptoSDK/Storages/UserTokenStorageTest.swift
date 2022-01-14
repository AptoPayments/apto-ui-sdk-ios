//
//  UserTokenStorageTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 24/03/2020.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class UserTokenStorageTest: XCTestCase {
    private var sut: UserTokenStorage! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let notificationHandler = NotificationHandlerFake()
    private let keychain = InMemoryKeychain()
    private let token = "token"
    private let primaryCredential = DataPointType.phoneNumber
    private let secondaryCredential = DataPointType.email
    private let tokenKey = "com.aptopayments.user.token"

    override func setUp() {
        super.setUp()

        sut = UserTokenStorage(notificationHandler: notificationHandler, keychain: keychain)
    }

    // MARK: - Notifications

    func testSetTokenRegisterForNotifications() {
        // Then
        XCTAssertTrue(notificationHandler.addObserverCalled)
    }

    func testSessionTokenExpiredNotificationClearCurrentSession() {
        // Given
        givenCurrentToken()
        XCTAssertNotNil(sut.currentToken())
        XCTAssertNotNil(keychain.value(for: tokenKey))

        // When
        notificationHandler.postNotification(.UserTokenSessionExpiredNotification)

        // Then
        XCTAssertNil(sut.currentToken())
        XCTAssertNil(keychain.value(for: tokenKey))
    }

    func testSessionTokenInvalidNotificationClearCurrentSession() {
        // Given
        givenCurrentToken()
        XCTAssertNotNil(sut.currentToken())
        XCTAssertNotNil(keychain.value(for: tokenKey))

        // When
        notificationHandler.postNotification(.UserTokenSessionInvalidNotification)

        // Then
        XCTAssertNil(sut.currentToken())
        XCTAssertNil(keychain.value(for: tokenKey))
    }

    func testSessionTokenClosedNotificationClearCurrentSession() {
        // Given
        givenCurrentToken()
        XCTAssertNotNil(sut.currentToken())
        XCTAssertNotNil(keychain.value(for: tokenKey))

        // When
        notificationHandler.postNotification(.UserTokenSessionClosedNotification)

        // Then
        XCTAssertNil(sut.currentToken())
        XCTAssertNil(keychain.value(for: tokenKey))
    }

    // MARK: - Token handling

    func testSetCurrentTokenPersistTokenToKeychain() {
        // When
        givenCurrentToken()

        // Then
        XCTAssertNotNil(keychain.value(for: tokenKey))
    }

    func testSetCurrentTokenCurrrentTokenReturnToken() {
        // Given
        givenCurrentToken()

        // When
        let currentToken = sut.currentToken()

        // Then
        XCTAssertEqual(token, currentToken)
    }

    func testSetCurrentTokenPrimaryCredentialReturnPrimaryCredential() {
        // Given
        givenCurrentToken()

        // When
        let credential = sut.currentTokenPrimaryCredential()

        // Then
        XCTAssertEqual(primaryCredential, credential)
    }

    func testSetCurrentTokenSecondaryCredentialReturnSecondaryCredential() {
        // Given
        givenCurrentToken()

        // When
        let credential = sut.currentTokenSecondaryCredential()

        // Then
        XCTAssertEqual(secondaryCredential, credential)
    }

    func testCurrentTokenLoadTokenFromKeychain() {
        // Given
        let data = currentTokenPersistedData()
        keychain.save(value: data, for: tokenKey)

        // When
        let currentToken = sut.currentToken()

        // Then
        XCTAssertEqual(token, currentToken)
    }

    func testPrimaryCredentialLoadCredentialFromKeychain() {
        // Given
        let data = currentTokenPersistedData()
        keychain.save(value: data, for: tokenKey)

        // When
        let credential = sut.currentTokenPrimaryCredential()

        // Then
        XCTAssertEqual(primaryCredential, credential)
    }

    func testSecondaryCredentialLoadCredentialFromKeychain() {
        // Given
        let data = currentTokenPersistedData()
        keychain.save(value: data, for: tokenKey)

        // When
        let credential = sut.currentTokenSecondaryCredential()

        // Then
        XCTAssertEqual(secondaryCredential, credential)
    }

    func testClearCurrentTokenRemoveValueFromKeychain() {
        // Given
        givenCurrentToken()

        // When
        sut.clearCurrentToken()

        // Then
        XCTAssertNil(keychain.value(for: tokenKey))
        XCTAssertNil(sut.currentToken())
    }

    // MARK: - Helpers

    private func givenCurrentToken() {
        sut.setCurrent(token: token, withPrimaryCredential: primaryCredential, andSecondaryCredential: secondaryCredential)
    }

    private func currentTokenPersistedData() -> Data? {
        givenCurrentToken()
        let data = keychain.value(for: tokenKey)
        sut.clearCurrentToken()
        return data
    }
}
