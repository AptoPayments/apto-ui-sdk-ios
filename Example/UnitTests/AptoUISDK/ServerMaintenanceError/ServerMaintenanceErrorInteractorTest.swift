//
//  ServerMaintenanceErrorInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class ServerMaintenanceErrorInteractorTest: XCTestCase {
    private var sut: ServerMaintenanceErrorInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var platform = serviceLocator.platformFake

    override func setUp() {
        super.setUp()

        sut = ServerMaintenanceErrorInteractor(aptoPlatform: platform)
    }

    func testRunPendingRequestCallNetworkManager() {
        // When
        sut.runPendingRequests()

        // Then
        XCTAssertTrue(platform.runPendingNetworkRequestsCalled)
    }
}
