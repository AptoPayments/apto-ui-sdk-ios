//
// UserPreferencesStorageTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/06/2019.
//

import XCTest
@testable import AptoSDK

class UserPreferencesStorageTest: XCTestCase {
  private var sut: UserPreferencesStorage! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let userDefaultsStorage = InMemoryUserDefaultsStorage()
  private let showDetailedCardActivityKey = "apto.sdk.showDetailedCardActivity"

  override func setUp() {
    super.setUp()
    sut = UserPreferencesStorage(userDefaultsStorage: userDefaultsStorage)
  }

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
}
