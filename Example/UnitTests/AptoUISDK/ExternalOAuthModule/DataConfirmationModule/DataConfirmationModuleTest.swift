//
//  DataConfirmationModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class DataConfirmationModuleTest: XCTestCase {
    var sut: DataConfirmationModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var presenter = serviceLocator.presenterLocatorFake.dataConfirmationPresenterSpy
    private let userData = ModelDataProvider.provider.emailDataPointList
    private let delegate = DataConfirmationModuleDelegateFake()

    override func setUp() {
        super.setUp()

        sut = DataConfirmationModule(serviceLocator: serviceLocator, userData: userData)
        sut.delegate = delegate
    }

    func testInitializeConfigurationSucceedConfigurePresenter() {
        // Given
        serviceLocator.setUpSessionForContextConfigurationSuccess()

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.analyticsManager)
    }

    func testInitializeConfigurationSucceedCallSuccess() {
        // Given
        var returnedResult: Result<UIViewController, NSError>?

        // When
        sut.initialize { result in
            returnedResult = result
        }

        // Then
        XCTAssertTrue(returnedResult!.isSuccess) // swiftlint:disable:this force_unwrapping
    }

    func testCloseCalledCallOnClose() {
        // Given
        var onCloseCalled = false
        sut.onClose = { _ in
            onCloseCalled = true
        }

        // When
        sut.close()

        // Then
        XCTAssertTrue(onCloseCalled)
    }

    func testCloseCalledDoNotCallOnFinish() {
        // Given
        var onFinishCalled = false
        sut.onFinish = { _ in
            onFinishCalled = true
        }

        // When
        sut.close()

        // Then
        XCTAssertFalse(onFinishCalled)
    }

    func testConfirmDataCalledCallOnFinish() {
        // Given
        var onFinishCalled = false
        sut.onFinish = { _ in
            onFinishCalled = true
        }

        // When
        sut.confirmData()

        // Then
        XCTAssertTrue(onFinishCalled)
    }

    func testConfirmDataCalledDoNotCallOnClose() {
        // Given
        var onCloseCalled = false
        sut.onClose = { _ in
            onCloseCalled = true
        }

        // When
        sut.confirmData()

        // Then
        XCTAssertFalse(onCloseCalled)
    }

    func testReloadUserDataCallDelegate() {
        // When
        sut.reloadUserData { _ in }

        // Then
        XCTAssertTrue(delegate.reloadUserDataCalled)
    }

    func testReloadUserDataFailsCallbackFailure() {
        // Given
        var returnedResult: Result<DataPointList, NSError>?
        delegate.nextReloadUserDataResult = .failure(BackendError(code: .other))

        // When
        sut.reloadUserData { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testReloadUserDataSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<DataPointList, NSError>?
        delegate.nextReloadUserDataResult = .success(userData)

        // When
        sut.reloadUserData { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testInitializeUpdateUserDataCallPresenter() {
        // Given
        sut.initialize { _ in }
        let presenter = serviceLocator.presenterLocatorFake.dataConfirmationPresenterSpy

        // When
        sut.updateUserData(userData)

        // Then
        XCTAssertTrue(presenter.updateUserDataCalled)
    }
}
