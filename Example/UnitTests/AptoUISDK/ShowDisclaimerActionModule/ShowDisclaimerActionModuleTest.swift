//
//  ShowDisclaimerActionModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class ShowDisclaimerActionModuleTest: XCTestCase {
    private var sut: ShowDisclaimerActionModule!

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let disclaimer: Content = .plainText("Disclaimer text")
    private lazy var dataProvider = ModelDataProvider.provider
    private lazy var workflowObject = dataProvider.cardApplication
    private var workflowAction: WorkflowAction {
        let action = dataProvider.workflowAction
        action.configuration = disclaimer

        return action
    }

    private lazy var disclaimerModule = serviceLocator.moduleLocatorFake.fullScreenDisclaimerModuleSpy
    private let analyticsManager = AnalyticsManagerSpy()

    override func setUp() {
        super.setUp()

        sut = ShowDisclaimerActionModule(serviceLocator: serviceLocator,
                                         workflowObject: workflowObject,
                                         workflowAction: workflowAction,
                                         actionConfirmer: ActionConfirmerFake.self,
                                         analyticsManager: analyticsManager)
    }

    func testInitializeAddFullScreenDisclaimerAsChild() {
        // When
        givenSUTInitialized()

        // Then
        XCTAssertTrue(disclaimerModule.initializeCalled)
        XCTAssertNotNil(disclaimerModule.onDisclaimerAgreed)
    }

    func testDisclaimerAgreedCallAcceptDisclaimer() {
        // Given
        givenSUTInitialized()
        let platform = serviceLocator.platformFake

        // When
        disclaimerModule.onDisclaimerAgreed!(disclaimerModule) // swiftlint:disable:this force_unwrapping

        // Then
        XCTAssertTrue(platform.acceptDisclaimerCalled)
    }

    func testAgreedDisclaimerSucceedCallOnFinish() {
        // Given
        var onFinishCalled = false
        sut.onFinish = { _ in
            onFinishCalled = true
        }
        givenSUTInitialized()
        givenSaveAgreementSucceed()
        // When
        disclaimerModule.onDisclaimerAgreed!(disclaimerModule) // swiftlint:disable:this force_unwrapping

        // Then
        XCTAssertTrue(onFinishCalled)
    }

    func testDisclaimerClosedShowConfirmation() {
        // Given
        givenSUTInitialized()

        // When
        disclaimerModule.close()

        // Then
        XCTAssertTrue(ActionConfirmerFake.confirmCalled)
    }

    func testDisclaimerCloseNotConfirmedDoNotClose() {
        // Given
        var onCloseCalled = false
        sut.onClose = { _ in
            onCloseCalled = true
        }
        givenSUTInitialized()
        ActionConfirmerFake.nextActionToExecute = .cancel

        // When
        disclaimerModule.close()

        // Then
        XCTAssertFalse(onCloseCalled)
    }

    func testDisclaimerCloseConfirmedCallCancelApplication() {
        // Given
        givenSUTInitialized()
        ActionConfirmerFake.nextActionToExecute = .ok
        let platform = serviceLocator.platformFake

        // When
        disclaimerModule.close()

        // Then
        XCTAssertTrue(platform.cancelCardApplicationCalled)
        XCTAssertEqual(platform.lastCancelCardApplicationApplicationId, workflowObject.id)
    }

    func testDisclaimerCancelConfirmedCancelApplicationCallBack() {
        // Given
        var onCloseCalled = false
        sut.onClose = { _ in
            onCloseCalled = true
        }
        givenSUTInitialized()
        ActionConfirmerFake.nextActionToExecute = .ok
        let platform = serviceLocator.platformFake
        platform.nextCancelCardApplicationResult = .success(())

        // When
        disclaimerModule.close()

        // Then
        XCTAssertTrue(onCloseCalled)
    }

    func testDisclaimerClosedLogDisclaimerReject() {
        // Given
        givenSUTInitialized()

        // When
        disclaimerModule.close()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.disclaimerRejectTap)
    }

    func testDisclaimerAgreedLogDisclaimerAccept() {
        // Given
        givenSUTInitialized()

        // When
        disclaimerModule.onDisclaimerAgreed!(disclaimerModule) // swiftlint:disable:this force_unwrapping

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(analyticsManager.lastEvent, Event.disclaimerAcceptTap)
    }

    private func givenSUTInitialized() {
        sut.initialize { _ in }
    }

    private func givenSaveAgreementSucceed() {
        let platform = serviceLocator.platformFake
        platform.nextAcceptDisclaimerResult = .success(())
    }
}
