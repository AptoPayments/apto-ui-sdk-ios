//
// UserPreferencesStorageTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/06/2019.
//

@testable import AptoSDK
import XCTest

class UserPreferencesStorageTest: XCTestCase {
    private var sut: UserPreferencesStorage! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let userDefaultsStorage = InMemoryUserDefaultsStorage()
    private let showDetailedCardActivityKey = "apto.sdk.showDetailedCardActivity"
    private let shouldUseBiometricKey = "apto.sdk.shouldUseBiometric"
    private let notificationHandler = NotificationHandlerFake()

    override func setUp() {
        super.setUp()
        sut = UserPreferencesStorage(userDefaultsStorage: userDefaultsStorage, notificationHandler: notificationHandler)
    }

    func testRegisterForNotifications() {
        // Then
        XCTAssertTrue(notificationHandler.addObserverCalled)
        XCTAssertTrue(notificationHandler.lastAddObserverObserver === sut)
    }

    // MARK: - show detailed card activity

    func testNoPreferenceSavedShowDetailedCardActivityIsFalse() {
        // When
        let value = sut.shouldShowDetailedCardActivity

        // Then
        XCTAssertFalse(value)
    }

    func testPreferenceSavedTrueShowDetailedCardActivityReturnSavedValue() {
        // Given
        userDefaultsStorage.set(true, forKey: showDetailedCardActivityKey)

        // When
        let value = sut.shouldShowDetailedCardActivity

        // Then
        XCTAssertTrue(value)
    }

    func testPreferenceSavedFalseShowDetailedCardActivityReturnSavedValue() {
        // Given
        userDefaultsStorage.set(false, forKey: showDetailedCardActivityKey)

        // When
        let value = sut.shouldShowDetailedCardActivity

        // Then
        XCTAssertFalse(value)
    }

    func testSetDetailedCardActivityPersistValue() {
        // When
        sut.shouldShowDetailedCardActivity = true

        // Then
        XCTAssertNotNil(userDefaultsStorage.object(forKey: showDetailedCardActivityKey))
    }

    // MARK: - should use biometric

    func testNoPreferenceSavedShouldUseBiometricIsFalse() {
        // When
        let value = sut.shouldUseBiometric

        // Then
        XCTAssertFalse(value)
    }

    func testPreferenceSavedTrueShouldUseBiometricReturnSavedValue() {
        // Given
        userDefaultsStorage.set(true, forKey: shouldUseBiometricKey)

        // When
        let value = sut.shouldUseBiometric

        // Then
        XCTAssertTrue(value)
    }

    func testPreferenceSavedFalseShouldUseBiometricReturnSavedValue() {
        // Given
        userDefaultsStorage.set(false, forKey: shouldUseBiometricKey)

        // When
        let value = sut.shouldUseBiometric

        // Then
        XCTAssertFalse(value)
    }

    func testSetShouldUseBiometricPersistValue() {
        // When
        sut.shouldUseBiometric = true

        // Then
        XCTAssertNotNil(userDefaultsStorage.object(forKey: shouldUseBiometricKey))
    }
}
