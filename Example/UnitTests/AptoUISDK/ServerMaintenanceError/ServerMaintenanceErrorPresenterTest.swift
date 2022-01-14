//
//  ServerMaintenanceErrorPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class ServerMaintenanceErrorPresenterTest: XCTestCase {
    private var sut: ServerMaintenanceErrorPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var router = serviceLocator.moduleLocatorFake.serverMaintenanceErrorModuleSpy
    private lazy var interactor = serviceLocator.interactorLocatorFake.serverMaintenanceErrorInteractorSpy
    private let analyticsManager = AnalyticsManagerSpy()

    override func setUp() {
        super.setUp()

        sut = ServerMaintenanceErrorPresenter()
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testRetryTappedNotifyRouterAndInteractor() {
        // When
        sut.retryTapped()

        // Then
        XCTAssertTrue(router.pendingRequestsExecutedCalled)
        XCTAssertTrue(interactor.runPendingRequestsCalled)
    }

    func testViewLoadedLogMaintenanceEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.maintenance)
    }
}
