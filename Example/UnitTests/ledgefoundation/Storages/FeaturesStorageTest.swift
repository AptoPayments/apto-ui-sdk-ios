//
// FeaturesStorageTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/05/2019.
//

import XCTest
@testable import AptoSDK

class FeaturesStorageTest: XCTestCase {
  private var sut: FeaturesStorage! // swiftlint:disable:this implicitly_unwrapped_optional

  override func setUp() {
    super.setUp()
    sut = FeaturesStorage()
  }

  func testEnabledFeatureIsFeatureEnabledReturnsTrue() {
    // Given
    sut.update(features: [.showStatsButton: true])

    // When
    let isEnabled = sut.isFeatureEnabled(.showStatsButton)

    // Then
    XCTAssertTrue(isEnabled)
  }

  func testDisabledFeatureIsFeatureEnabledReturnsFalse() {
    // Given
    sut.update(features: [.showStatsButton: false])

    // When
    let isEnabled = sut.isFeatureEnabled(.showStatsButton)

    // Then
    XCTAssertFalse(isEnabled)
  }

  func testFeatureNotSetIsFeatureEnabledReturnsFalse() {
    // Given
    sut.update(features: [:])

    // When
    let isEnabled = sut.isFeatureEnabled(.showStatsButton)

    // Then
    XCTAssertFalse(isEnabled)
  }
}
