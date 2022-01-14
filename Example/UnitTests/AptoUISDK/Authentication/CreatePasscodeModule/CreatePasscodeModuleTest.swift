//
//  CreatePasscodeModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class CreatePasscodeModuleTest: XCTestCase {
    private var sut: CreatePasscodeModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()

    override func setUp() {
        super.setUp()
        sut = CreatePasscodeModule(serviceLocator: serviceLocator)
    }

    func testInitializeCompleteSucceed() {
        // Given
        var returnedResult: Result<UIViewController, NSError>?

        // When
        sut.initialize { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testInitializeSetUpPresenter() {
        // Given
        let presenter = serviceLocator.presenterLocatorFake.createPasscodePresenter()
        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.analyticsManager)
    }
}
