//
//  BiometricPermissionModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class BiometricPermissionModuleTest: XCTestCase {
    private var sut: BiometricPermissionModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()

    override func setUp() {
        super.setUp()
        sut = BiometricPermissionModule(serviceLocator: serviceLocator)
    }

    func testInitializeCompleteSucceed() {
        // When
        sut.initialize { result in
            // Then
            XCTAssertTrue(result.isSuccess)
        }
    }

    func testInitializeSetUpPresenter() {
        // Given
        let presenter = serviceLocator.presenterLocatorFake.biometricPermissionPresenter()

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.analyticsManager)
    }
}
