//
//  BiometricPermissionInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class BiometricPermissionInteractorTest: XCTestCase {
  private var sut: BiometricPermissionInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let platform = AptoPlatformFake()

  override func setUp() {
    super.setUp()

    sut = BiometricPermissionInteractor(platform: platform)
  }

  func testSetIsBiometricPermissionEnabledCallPlatform() {
    // Given
    let possibleValues = [true, false]

    for value in possibleValues {
      // When
      sut.setBiometricPermissionEnabled(value)

      // Then
      XCTAssertTrue(platform.setIsBiometricEnabledCalled)
      XCTAssertEqual(value, platform.lastIsBiometricEnabled)
    }
  }
}
