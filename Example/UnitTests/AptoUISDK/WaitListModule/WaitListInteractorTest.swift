//
// WaitListInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 27/02/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class WaitListInteractorTest: XCTestCase {
    private var sut: WaitListInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let application = ModelDataProvider.provider.cardApplication
    private let serviceLocator = ServiceLocatorFake()
    private lazy var platform = serviceLocator.platformFake

    override func setUp() {
        super.setUp()

        sut = WaitListInteractor(application: application, platform: platform)
    }

    func testReloadApplicationCallCardSession() {
        // When
        sut.reloadApplication { _ in }

        // Then
        XCTAssertTrue(platform.fetchCardApplicationStatusCalled)
    }

    func testApplicationStatusFailCallbackFailure() {
        // Given
        var returnedResult: Result<CardApplication, NSError>?
        platform.nextFetchCardApplicationStatusResult = .failure(BackendError(code: .other))

        // When
        sut.reloadApplication { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testApplicationStatusSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<CardApplication, NSError>?
        platform.nextFetchCardApplicationStatusResult = .success(ModelDataProvider.provider.cardApplication)

        // When
        sut.reloadApplication { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }
}
