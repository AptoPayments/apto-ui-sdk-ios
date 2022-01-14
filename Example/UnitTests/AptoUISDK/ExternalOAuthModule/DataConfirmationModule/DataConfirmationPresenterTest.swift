//
//  DataConfirmationPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class DataConfirmationPresenterTest: XCTestCase {
    var sut: DataConfirmationPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let router = DataConfirmationModuleFake(serviceLocator: ServiceLocatorFake())
    private let interactor = DataConfirmationInteractorFake()
    private let userData = ModelDataProvider.provider.emailDataPointList
    private let analyticsManager = AnalyticsManagerSpy()

    override func setUp() {
        super.setUp()

        sut = DataConfirmationPresenter()
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testViewLoadedCallInteractorToProvideData() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(interactor.provideUserDataCalled)
    }

    func testInteractorProvideDataUpdateViewModel() {
        // Given
        interactor.nextUserData = userData

        // When
        sut.viewLoaded()

        // Then
        XCTAssertEqual(userData, sut.viewModel.userData.value)
    }

    func testConfirmDataTappedNotifyRouter() {
        // When
        sut.confirmDataTapped()

        // Then
        XCTAssertTrue(router.confirmDataCalled)
    }

    func testCloseTappedNotifyRouter() {
        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(router.closeCalled)
    }

    func testShowURLNotifyRouter() {
        // Given
        let url = URL(string: "https://aptopayments.com")! // swiftlint:disable:this force_unwrapping

        // When
        sut.show(url: url)

        // Then
        XCTAssertTrue(router.showURLCalled)
    }

    func testViewLoadedLogSelectBalanceStoreOauthConfirmEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirm)
    }

    func testReloadTappedCallRouter() {
        // When
        sut.reloadTapped()

        // Then
        XCTAssertTrue(router.reloadUserDataCalled)
    }

    func testReloadUserDataFailsUpdateViewModelErrorProperty() {
        // Given
        router.nextReloadUserDataResult = .failure(BackendError(code: .other))

        // When
        sut.reloadTapped()

        // Then
        XCTAssertNotNil(sut.viewModel.error.value)
    }

    func testReloadUserDataSucceedUpdateViewModelUserDataProperty() {
        // Given
        router.nextReloadUserDataResult = .success(userData)

        // When
        sut.reloadTapped()

        // Then
        XCTAssertNotNil(sut.viewModel.userData.value)
    }

    func testUpdateUserDataUpdateViewModel() {
        // When
        sut.updateUserData(userData)

        // Then
        XCTAssertNotNil(sut.viewModel.userData.value)
    }

    func testOnConfirmDataTappedLogSelectBalanceStoreOauthConfirmEvent() {
        // When
        sut.confirmDataTapped()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmTap)
    }

    func testOnRefreshDetailsTappedLogSelectBalanceStoreOauthConfirmRefreshDetailsEvent() {
        // When
        sut.reloadTapped()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmRefreshDetailsTap)
    }

    func testOnBackTappedLogSelectBalanceStoreOauthConfirmBackEvent() {
        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmConfirmBackTap)
    }
}
