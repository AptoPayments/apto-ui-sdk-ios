//
// CardSettingsInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 28/06/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class CardSettingsInteractorTest: XCTestCase {
    private var sut: CardSettingsInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var platform = serviceLocator.platformFake

    override func setUp() {
        super.setUp()
        sut = CardSettingsInteractor(platform: platform)
    }

    func testIsShowDetailedCardActivityEnabledCallPlatform() {
        // When
        _ = sut.isShowDetailedCardActivityEnabled()

        // Then
        XCTAssertTrue(platform.isShowDetailedCardActivityEnabledCalled)
    }

    func testPlatformIsSetToTrueIsShowDetailedCardActivityEnabledReturnTrue() {
        // Given
        platform.nextIsShowDetailedCardActivityEnabledResult = true

        // When
        let result = sut.isShowDetailedCardActivityEnabled()

        // Then
        XCTAssertTrue(result)
    }

    func testPlatformIsSetToFalseIsShowDetailedCardActivityEnabledReturnFalse() {
        // Given
        platform.nextIsShowDetailedCardActivityEnabledResult = false

        // When
        let result = sut.isShowDetailedCardActivityEnabled()

        // Then
        XCTAssertFalse(result)
    }

    func testSetShowDetailedCardActivityEnabledCallPlatform() {
        // When
        sut.setShowDetailedCardActivityEnabled(true)

        // Then
        XCTAssertTrue(platform.setShowDetailedCardActivityEnabledCalled)
    }
}
