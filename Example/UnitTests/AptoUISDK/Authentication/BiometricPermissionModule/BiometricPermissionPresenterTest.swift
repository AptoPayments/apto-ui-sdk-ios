//
//  BiometricPermissionPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class BiometricPermissionPresenterTest: XCTestCase {
    private var sut: BiometricPermissionPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let router = BiometricPermissionModuleFake(serviceLocator: ServiceLocatorFake())
    private let interactor = BiometricPermissionInteractorFake()
    private let analyticsManager = AnalyticsManagerSpy()

    override func setUp() {
        super.setUp()

        sut = BiometricPermissionPresenter()
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testViewLoadedTrackAnalyticsEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(Event.biometricPermissionStart, analyticsManager.lastEvent)
    }

    func testCloseTappedAskRouterToClose() {
        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(interactor.setIsBiometricPermissionEnabledCalled)
        XCTAssertEqual(false, interactor.lastIsBiometricPermissionEnabled)
        XCTAssertTrue(router.closeCalled)
    }

    func testRequestPermissionTappedAskRouterToRequestPermission() {
        // When
        sut.requestPermissionTapped()

        // Then
        XCTAssertTrue(router.requestBiometricPermissionCalled)
    }

    func testPermissionGrantedAskRouterToFinish() {
        // Given
        router.nextRequestBiometricPermissionGrantedResult = true

        // When
        sut.requestPermissionTapped()

        // Then
        XCTAssertTrue(interactor.setIsBiometricPermissionEnabledCalled)
        XCTAssertEqual(true, interactor.lastIsBiometricPermissionEnabled)
        XCTAssertTrue(router.finishCalled)
    }

    func testPermissionDeniedAskRouterToClose() {
        // Given
        router.nextRequestBiometricPermissionGrantedResult = false

        // When
        sut.requestPermissionTapped()

        // Then
        XCTAssertTrue(interactor.setIsBiometricPermissionEnabledCalled)
        XCTAssertEqual(false, interactor.lastIsBiometricPermissionEnabled)
        XCTAssertTrue(router.closeCalled)
    }
}
