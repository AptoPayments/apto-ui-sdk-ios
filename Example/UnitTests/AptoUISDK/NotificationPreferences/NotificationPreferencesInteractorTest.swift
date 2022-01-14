//
// NotificationPreferencesInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/03/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class NotificationPreferencesInteractorTest: XCTestCase {
    private var sut: NotificationPreferencesInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var platform = serviceLocator.platformFake
    private let notificationPreferences = ModelDataProvider.provider.notificationPreferences

    override func setUp() {
        super.setUp()

        sut = NotificationPreferencesInteractor(platform: platform)
    }

    func testFetchPreferencesCallSession() {
        // When
        sut.fetchPreferences { _ in }

        // Then
        XCTAssertTrue(platform.fetchNotificationPreferencesCalled)
    }

    func testGetNotificationPreferencesFailsCallbackFailure() {
        // Given
        var returnedResult: Result<NotificationPreferences, NSError>?
        platform.nextFetchNotificationPreferencesResult = .failure(BackendError(code: .other))

        // When
        sut.fetchPreferences { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testGetNotificationPreferencesSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<NotificationPreferences, NSError>?
        platform.nextFetchNotificationPreferencesResult = .success(notificationPreferences)

        // When
        sut.fetchPreferences { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
        XCTAssertTrue(returnedResult?.value === notificationPreferences)
    }

    func testUpdatePreferencesCallSession() {
        // When
        sut.updatePreferences(notificationPreferences) { _ in }

        // Then
        XCTAssertTrue(platform.updateNotificationPreferencesCalled)
        XCTAssertTrue(platform.lastUpdateNotificationPreferencesPreferences === notificationPreferences)
    }

    func testUpdatePreferencesFailsCallbackFailure() {
        // Given
        var returnedResult: Result<NotificationPreferences, NSError>?
        platform.nextUpdateNotificationPreferencesResult = .failure(BackendError(code: .other))

        // When
        sut.updatePreferences(notificationPreferences) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testUpdatePreferencesSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<NotificationPreferences, NSError>?
        platform.nextUpdateNotificationPreferencesResult = .success(notificationPreferences)

        // When
        sut.updatePreferences(notificationPreferences) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }
}
