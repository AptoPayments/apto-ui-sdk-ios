//
//  VerifyPasscodeModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class VerifyPasscodeModuleTest: XCTestCase {
    private var sut: VerifyPasscodeModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var platfom = serviceLocator.platformFake

    override func setUp() {
        super.setUp()
        sut = VerifyPasscodeModule(serviceLocator: serviceLocator, actionConfirmer: ActionConfirmerFake.self)
    }

    func testInitializeCalledFetchContextConfiguration() {
        // When
        sut.initialize { _ in }

        // Then
        XCTAssertTrue(platfom.fetchContextConfigurationCalled)
    }

    func testFetchConfigurationSucceedCallbackSuccess() {
        // Given
        platfom.nextFetchContextConfigurationResult = .success(ModelDataProvider.provider.contextConfiguration)

        // When
        sut.initialize { result in
            // Then
            XCTAssertTrue(result.isSuccess)
        }
    }

    func testInitializeSetUpPresenter() {
        // Given
        platfom.nextFetchContextConfigurationResult = .success(ModelDataProvider.provider.contextConfiguration)
        let presenter = serviceLocator.presenterLocatorFake.verifyPasscodePresenterSpy

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.analyticsManager)
    }

    func testFetchConfigurationFailsCallbackFailure() {
        // Given
        platfom.nextFetchContextConfigurationResult = .failure(BackendError(code: .other))

        // When
        sut.initialize { result in
            // Then
            XCTAssertTrue(result.isFailure)
        }
    }

    func testShowForgotPIN() {
        // When
        sut.showForgotPIN()

        // Then
        XCTAssertTrue(ActionConfirmerFake.confirmCalled)
    }

    func testShowPINActionConfirmedCallLogout() {
        // Given
        ActionConfirmerFake.nextActionToExecute = .ok

        // When
        sut.showForgotPIN()

        // Then
        XCTAssertTrue(platfom.logoutCalled)
    }

    func testShowPINActionCanceledLogoutNotCalled() {
        // Given
        ActionConfirmerFake.nextActionToExecute = .cancel

        // When
        sut.showForgotPIN()

        // Then
        XCTAssertFalse(platfom.logoutCalled)
    }
}
