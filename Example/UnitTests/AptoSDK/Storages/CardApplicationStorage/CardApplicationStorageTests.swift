//
//  CardApplicationStorageTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 24/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import AptoSDK

class CardApplicationStorageTests: XCTestCase, CardApplicationSpecs {

    func test_init_doesNotRequestDataFromURL() {
        let (_, transport) = makeSUT()
        assertThatInitDoesNotRequestDataFromURL(on: transport)
    }

    // MARK: issueCard tests
    func test_issueCard_postDataToURL() {
        let (sut, transport) = makeSUT()
        assertThatIssueCardPostDataToURL(on: sut, transport: transport,
                                         applicationId: anyApplicationId(),
                                         metadata: anyMetadata(),
                                         design: anyDesign())
    }

    func test_issueCardTwice_postDataToURLTwice() {
        let (sut, transport) = makeSUT()
        assertThatIssueCardTwicePostDataToURLTwice(on: sut, transport: transport,
                                                   applicationId: anyApplicationId(),
                                                   metadata: anyMetadata(),
                                                   design: anyDesign())
    }

    func test_issueCard_deliversErrorOnClientErrors() {
        let (sut, transport) = makeSUT()
        assertThatIssueCardDeliversErrorOnClientErrors(on: sut, transport: transport,
                                                       applicationId: anyApplicationId(),
                                                       metadata: anyMetadata(),
                                                       design: anyDesign())
    }

    func test_issueCard_deliversNewCardOnValidJSONResponse() {
        let (sut, transport) = makeSUT()
        asserThatIssueCardDeliversNewCardOnValidJSONResponse(on: sut, transport: transport,
                                                             applicationId: anyApplicationId(),
                                                             metadata: anyMetadata(),
                                                             design: anyDesign())
    }

    // MARK: createApplication tests
    func test_createApplication_postDataToURL() {
        let (sut, transport) = makeSUT()
        assertThatCreateApplicationPostDataToURL(on: sut, transport: transport)
    }

    func test_createApplication_postDataToURLTwice() {
        let (sut, transport) = makeSUT()
        assertThatCreateApplicationPostDataToURLTwice(on: sut, transport: transport)
    }

    func test_createApplication_deliversErrorOnClientErrors() {
        let (sut, transport) = makeSUT()
        assertThatCreateApplicationDeliversErrorOnClientErrors(on: sut, transport: transport)
    }

    func test_createApplication_deliversNewApplicationOnValidJSONResponse() {
        let (sut, transport) = makeSUT()
        assertThatCreateApplicationDeliversNewApplicationOnValidJSONResponse(on: sut, transport: transport)
    }

    // MARK: applicationStatus tests
    func test_applicationStatus_getDataFromURL() {
        let (sut, transport) = makeSUT()
        assertThatApplicationStatusGetDataFromURL(on: sut, transport: transport, applicationId: anyApplicationId())
    }
    
    func test_applicationStatusTwice_getDataFromURLTwice() {
        let (sut, transport) = makeSUT()
        assertThatApplicationStatusTwiceGetDataToURLTwice(on: sut, transport: transport, applicationId: anyApplicationId())
    }
    
    func test_applicationStatus_deliversErrorOnClientErrors() {
        let (sut, transport) = makeSUT()
        assertThatApplicationStatusDeliversErrorOnClientErrors(on: sut, transport: transport, applicationId: anyApplicationId())
    }
    
        func test_applicationStatus_deliversApplicationOnValidJSONResponse() {
        let (sut, transport) = makeSUT()
        assertThatApplicationStatusDeliversApplicationOnValidJSONResponse(on: sut, transport: transport, applicationId: anyApplicationId())
    }

    // MARK: setBalanceStore tests
    func test_setBalanceStore_postDataToURL() {
        let (sut, transport) = makeSUT()
        assertThatSetBalanceStorePostDataToURL(on: sut, transport: transport, applicationId: anyApplicationId())
    }
    
    func test_setBalanceStore_postDataToURLTwice() {
        let (sut, transport) = makeSUT()
        assertThatSetBalanceStorePostDataToURLTwice(on: sut, transport: transport, applicationId: anyApplicationId())
    }
    
    func test_setBalanceStore_deliversErrorOnClientErrors() {
        let (sut, transport) = makeSUT()
        assertThatSetBalanceStoreDeliversErrorOnClientErrors(on: sut, transport: transport, applicationId: anyApplicationId())
    }
    
    func test_setBalanceStore_deliversNewApplicationOnValidJSONResponse() {
        let (sut, transport) = makeSUT()
        assertThatSetBalanceStoreDeliversSelectBalanceStoreResultOnValidJSONResponse(on: sut, transport: transport, applicationId: anyApplicationId())
    }

    // MARK: acceptDisclaimer tests
    func test_acceptDisclaimer_postDataToURL() {
        let (sut, transport) = makeSUT()
        assertThatAcceptDisclaimerPostDataToURL(on: sut,
                                                transport: transport,
                                                workflowObject: ModelDataProvider.provider.cardApplication,
                                                workflowAction: ModelDataProvider.provider.workflowAction)
    }
    
    func test_acceptDisclaimer_postDataToURLTwice() {
        let (sut, transport) = makeSUT()
        assertThatAcceptDisclaimerPostDataToURLTwice(on: sut,
                                                     transport: transport,
                                                     workflowObject: ModelDataProvider.provider.cardApplication,
                                                     workflowAction: ModelDataProvider.provider.workflowAction)
    }
    
    func test_acceptDisclaimer_deliversErrorOnClientErrors() {
        let (sut, transport) = makeSUT()
        assertThatAcceptDisclaimerDeliversErrorOnClientErrors(on: sut,
                                                              transport: transport,
                                                              workflowObject: ModelDataProvider.provider.cardApplication,
                                                              workflowAction: ModelDataProvider.provider.workflowAction)
    }
    
    func test_acceptDisclaimer_deliversSuccessOnValidJSONResponse() {
        let (sut, transport) = makeSUT()
        assertThatAcceptDisclaimerDeliversNewApplicationOnValidJSONResponse(on: sut,
                                                                            transport: transport,
                                                                            workflowObject: ModelDataProvider.provider.cardApplication,
                                                                            workflowAction: ModelDataProvider.provider.workflowAction)
    }

    // MARK: cancelCardApplication tests
    func test_cancelCardApplication_deleteDataFromURL() {
        let (sut, transport) = makeSUT()
        assertThatCancelCardApplicationDeleteDataFromURL(on: sut,
                                                         transport: transport,
                                                         applicationId: anyApplicationId())
    }
    
    func test_cancelCardApplication_deleteDataFromURLTwice() {
        let (sut, transport) = makeSUT()
        assertThatCancelCardApplicationDeleteDataFromURLTwice(on: sut,
                                                              transport: transport,
                                                              applicationId: anyApplicationId())
    }
    
    func test_cancelCardApplication_deliversErrorOnClientErrors() {
        let (sut, transport) = makeSUT()
        assertThatCancelCardApplicationDeliversErrorOnClientErrors(on: sut,
                                                                   transport: transport,
                                                                   applicationId: anyApplicationId())
    }
    
    func test_cancelCardApplication_deliversNewApplicationOnValidJSONResponse() {
        let (sut, transport) = makeSUT()
        assertThatCancelCardApplicationDeliversNewApplicationOnValidJSONResponse(on: sut,
                                                                                 transport: transport,
                                                                                 applicationId: anyApplicationId())
    }

    // MARK: Private Helper methods
    private func makeSUT() -> (sut: CardApplicationsStorageProtocol, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let sut = CardApplicationsStorage(transport: transport)
        return (sut, transport)
    }
}
