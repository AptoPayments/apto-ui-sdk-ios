//
//  ChangePasscodeModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//

@testable import AptoUISDK
import XCTest

class ChangePasscodeModuleTest: XCTestCase {
    private var sut: ChangePasscodeModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()

    override func setUp() {
        super.setUp()

        sut = ChangePasscodeModule(serviceLocator: serviceLocator, actionConfirmer: ActionConfirmerFake.self)
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
        let presenter = serviceLocator.presenterLocatorFake.changePasscodePresenter()

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.analyticsManager)
    }

    func testShowForgotPasscode() {
        // When
        sut.showForgotPasscode()

        // Then
        XCTAssertTrue(ActionConfirmerFake.confirmCalled)
    }

    func testShowPasscodeActionConfirmedCallLogout() {
        // Given
        ActionConfirmerFake.nextActionToExecute = .ok

        // When
        sut.showForgotPasscode()

        // Then
        XCTAssertTrue(serviceLocator.platformFake.logoutCalled)
    }

    func testShowPasscodeActionCanceledLogoutNotCalled() {
        // Given
        ActionConfirmerFake.nextActionToExecute = .cancel

        // When
        sut.showForgotPasscode()

        // Then
        XCTAssertFalse(serviceLocator.platformFake.logoutCalled)
    }
}
