//
//  PhysicalCardActivationSucceedPresenterTest.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class PhysicalCardActivationSucceedPresenterTest: XCTestCase {
    var sut: PhysicalCardActivationSucceedPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var router = serviceLocator.moduleLocatorFake.physicalCardActivationSucceedModuleFake
    private lazy var interactor = serviceLocator.interactorLocatorFake.physicalCardActivationSucceedInteractorFake
    private let analyticsManager = AnalyticsManagerSpy()

    override func setUp() {
        super.setUp()

        sut = PhysicalCardActivationSucceedPresenter()
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testViewLoadedCallProvideCard() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(interactor.provideCardCalled)
    }

    func testCardProvidedWithIVRShowGetPinIsTrue() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(sut.viewModel.showGetPinButton.value)
        XCTAssertTrue(sut.viewModel.showChargeLabel.value)
    }

    func testCardProvidedWithVoIPShowGetPinIsTrue() {
        // Given
        interactor.card = ModelDataProvider.provider.cardWithVoIP

        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(sut.viewModel.showGetPinButton.value)
        XCTAssertTrue(sut.viewModel.showChargeLabel.value)
    }

    func testCardProvidedWithChangePinShowGetPinIsTrue() {
        // Given
        interactor.card = ModelDataProvider.provider.cardWithChangePIN

        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(sut.viewModel.showGetPinButton.value)
        XCTAssertFalse(sut.viewModel.showChargeLabel.value)
    }

    func testCardProvidedWithChangePinAndIVRPinShowGetPinIsTrue() {
        // Given
        interactor.card = ModelDataProvider.provider.cardWithChangePINAndIVR

        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(sut.viewModel.showGetPinButton.value)
        XCTAssertFalse(sut.viewModel.showChargeLabel.value)
    }

    func testCardProvidedWithoutIVRAndChangePinShowGetPinIsFalse() {
        // Given
        interactor.card = ModelDataProvider.provider.card

        // When
        sut.viewLoaded()

        // Then
        XCTAssertFalse(sut.viewModel.showGetPinButton.value)
        XCTAssertFalse(sut.viewModel.showChargeLabel.value)
    }

    func testCardProvidedWithUnknownSourceShowGetPinIsFalse() {
        // Given
        interactor.card = ModelDataProvider.provider.cardWithUnknownSource

        // When
        sut.viewLoaded()

        // Then
        XCTAssertFalse(sut.viewModel.showGetPinButton.value)
        XCTAssertFalse(sut.viewModel.showChargeLabel.value)
    }

    func testViewLoadedCardWithIVRCardGetPinTappedShowExternalURL() {
        // Given
        sut.viewLoaded()

        // When
        sut.getPinTapped()

        // Then
        XCTAssertTrue(router.callURLCalled)
        XCTAssertFalse(router.showSetPinCalled)
        XCTAssertFalse(router.showVoIPCalled)
    }

    func testViewLoadedCardWithVoIPGetPinTappedShowVoIP() {
        // Given
        interactor.card = ModelDataProvider.provider.cardWithVoIP
        sut.viewLoaded()

        // When
        sut.getPinTapped()

        // Then
        XCTAssertTrue(router.showVoIPCalled)
        XCTAssertFalse(router.callURLCalled)
        XCTAssertFalse(router.showSetPinCalled)
    }

    func testViewLoadedCardWithChangePinCardGetPinTappedShowSetPin() {
        // Given
        interactor.card = ModelDataProvider.provider.cardWithChangePIN
        sut.viewLoaded()

        // When
        sut.getPinTapped()

        // Then
        XCTAssertTrue(router.showSetPinCalled)
        XCTAssertFalse(router.callURLCalled)
        XCTAssertFalse(router.showVoIPCalled)
    }

    func testViewLoadedCardWithChangePinAndIVRCardGetPinTappedShowSetPin() {
        // Given
        interactor.card = ModelDataProvider.provider.cardWithChangePINAndIVR
        sut.viewLoaded()

        // When
        sut.getPinTapped()

        // Then
        XCTAssertTrue(router.showSetPinCalled)
        XCTAssertFalse(router.callURLCalled)
        XCTAssertFalse(router.showVoIPCalled)
    }

    func testViewLoadedNotCalledGetPinDoNothing() {
        // When
        sut.getPinTapped()

        // Then
        XCTAssertFalse(router.showSetPinCalled)
        XCTAssertFalse(router.getPinFinishedCalled)
    }

    func testGetPinTappedWithoutIVRDoNotOpenURLCallFinished() {
        // Given
        interactor.card = ModelDataProvider.provider.card
        sut.viewLoaded()

        // When
        sut.getPinTapped()

        // Then
        XCTAssertFalse(router.callURLCalled)
        XCTAssertTrue(router.getPinFinishedCalled)
        XCTAssertFalse(router.showVoIPCalled)
    }

    func testCloseTappedCallClose() {
        // Given
        sut.viewLoaded()

        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(router.closeCalled)
    }

    func testCardWithoutIVRAndChangePinCloseTappedCallGetPinFinished() {
        // Given
        interactor.card = ModelDataProvider.provider.card
        sut.viewLoaded()

        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(router.getPinFinishedCalled)
    }

    func testViewLoadedLogManageCardActivatePhysicalCardEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.manageCardActivatePhysicalCard)
    }
}
