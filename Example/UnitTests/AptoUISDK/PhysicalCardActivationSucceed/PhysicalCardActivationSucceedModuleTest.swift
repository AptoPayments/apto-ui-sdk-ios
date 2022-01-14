//
//  PhysicalCardActivationSucceedModuleTest.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class PhysicalCardActivationSucceedModuleTest: XCTestCase {
    var sut: PhysicalCardActivationSucceedModule! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let card = ModelDataProvider.provider.card
    private lazy var presenter = serviceLocator.presenterLocatorFake.physicalCardActivationSucceedPresenterSpy
    private let phoneCaller = PhoneCallerSpy()

    override func setUp() {
        super.setUp()

        sut = PhysicalCardActivationSucceedModule(serviceLocator: serviceLocator, card: card, phoneCaller: phoneCaller)
    }

    func testContextConfigurationSucceedConfigurePresenter() {
        // Given
        serviceLocator.setUpSessionForContextConfigurationSuccess()

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.interactor)
    }

    func testShowExternalURLCallCompletion() {
        // Given
        var completionCalled = false

        // When
        sut.call(url: URL(string: "https://aptopayments.com")!) { // swiftlint:disable:this force_unwrapping
            completionCalled = true
        }

        // Then
        XCTAssertTrue(phoneCaller.callCalled)
        XCTAssertTrue(completionCalled)
    }

    func testGetPinFinishedCalledCallOnFinish() {
        // Given
        var onFinishCalled = false
        sut.onFinish = { _ in
            onFinishCalled = true
        }

        // When
        sut.getPinFinished()

        // Then
        XCTAssertTrue(onFinishCalled)
    }

    func testShowVoIPPresentVoIPModule() {
        // Given
        let voIPModule = serviceLocator.moduleLocatorFake.voIPModuleSpy

        // When
        sut.showVoIP()

        // Then
        XCTAssertTrue(voIPModule.initializeCalled)
    }

    func testVoIPPresentedOnFinishCallOnFinish() {
        // Given
        var onFinishCalled = false
        sut.onFinish = { _ in
            onFinishCalled = true
        }
        sut.showVoIP()
        let voIPModule = serviceLocator.moduleLocatorFake.voIPModuleSpy

        // When
        voIPModule.finish(result: nil)

        // Then
        XCTAssertTrue(onFinishCalled)
    }
}
