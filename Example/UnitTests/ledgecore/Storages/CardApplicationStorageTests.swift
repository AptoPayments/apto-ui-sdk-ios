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

class CardApplicationStorageTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, transport) = makeSUT()

        XCTAssertFalse(transport.getCalled)
        XCTAssertFalse(transport.postCalled)
        XCTAssertTrue(transport.requestesURLs.isEmpty)
    }

    // MARK: issueCard tests
    func test_issueCard_postDataToURL() throws {
        let (sut, transport) = makeSUT()
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.issueCard)

        sut.issueCard(apiKey(),
                      userToken: userToken(),
                      applicationId: anyApplicationId(),
                      additionalFields: anyAdditionalFields(),
                      metadata: anyMetadata(),
                      design: anyDesign()) { _ in }
        
        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }

    func test_issueCardTwice_postDataToURLTwice() throws {
        let (sut, transport) = makeSUT()
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.issueCard)

        sut.issueCard(apiKey(),
                      userToken: userToken(),
                      applicationId: anyApplicationId(),
                      additionalFields: anyAdditionalFields(),
                      metadata: anyMetadata(),
                      design: anyDesign()) { _ in }
        sut.issueCard(apiKey(),
                      userToken: userToken(),
                      applicationId: anyApplicationId(),
                      additionalFields: anyAdditionalFields(),
                      metadata: anyMetadata(),
                      design: anyDesign()) { _ in }

        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()])
    }

    func test_issueCard_deliversErrorOnClientErrors() throws {
        let (sut, transport) = makeSUT()
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectIssueCard(sut,
                        toCompleteWith: .failure(clientError),
                        apiKey: apiKey(),
                        userToken: userToken(),
                        applicationId: anyApplicationId(),
                        additionalFields: anyAdditionalFields(),
                        metadata: anyMetadata(),
                        design: anyDesign()) {
            transport.complete(with: clientError)
        }
    }

    func test_issueCard_deliversNewCardOnValidJSONResponse() throws {
        let (sut, transport) = makeSUT()
        let item = makeIssueCard()
        
        var capturedResults = [Result<Card, NSError>]()
        sut.issueCard(apiKey(),
                      userToken: userToken(),
                      applicationId: anyApplicationId(),
                      additionalFields: anyAdditionalFields(),
                      metadata: anyMetadata(),
                      design: anyDesign()) { capturedResults.append($0) }
        transport.complete(withResult: item.json)

        XCTAssertEqual(try capturedResults[0].get().metadata, anyMetadata())
    }

    // MARK: Private Helper methods
    private func makeSUT() -> (sut: CardApplicationsStorage, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let sut = CardApplicationsStorage(transport: transport)
        return (sut, transport)
    }

    private func expectIssueCard(_ sut: CardApplicationsStorage,
                                 toCompleteWith result: Result<Card, NSError>,
                                 apiKey: String,
                                 userToken: String,
                                 applicationId: String,
                                 additionalFields: [String : AnyObject]?,
                                 metadata: String?,
                                 design: IssueCardDesign?,
                                 when action: () -> Void) {
        
        var capturedResults = [Result<Card, NSError>]()
        sut.issueCard(apiKey,
                      userToken: userToken,
                      applicationId: applicationId,
                      additionalFields: additionalFields,
                      metadata: metadata,
                      design: design) { capturedResults.append($0) }
        
        action()
            
        XCTAssertEqual(capturedResults , [result])
    }
    
    private func makeIssueCard() -> (cardDetail: Card, json: JSON) {
        let card: JSON = [
            "type": "card",
            "account_id": "crd_5a34ba3d58ca34d2",
            "metadata": anyMetadata(),
            "state": "active",
            "ordered_status": "available",
            "last_four": "1234",
        ]
        return (ModelDataProvider.provider.cardWithMetadata, card)
    }
    
    private func apiKey() -> String { "api_key" }
    private func userToken() -> String { "user_token" }
    private func anyApplicationId() -> String { "any application id" }
    private func anyMetadata() -> String { "any metadata" }
    private func anyAdditionalFields() -> [String : AnyObject] { ["field": "value" as AnyObject] }
    private func anyDesign() -> IssueCardDesign { ModelDataProvider.provider.design }
}

class CardApplicationStorageSpy: CardApplicationsStorageProtocol {
    func nextApplications(_ apiKey: String, userToken: String, page: Int, rows: Int, callback: @escaping Result<[CardApplication], NSError>.Callback) {}
    
    func createApplication(_ apiKey: String, userToken: String, cardProduct: CardProduct, callback: @escaping Result<CardApplication, NSError>.Callback) {}
    
    func applicationStatus(_ apiKey: String, userToken: String, applicationId: String, callback: @escaping Result<CardApplication, NSError>.Callback) {}
    
    func setBalanceStore(_ apiKey: String, userToken: String, applicationId: String, custodian: Custodian, callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {}
    
    func acceptDisclaimer(_ apiKey: String, userToken: String, workflowObject: WorkflowObject, workflowAction: WorkflowAction, callback: @escaping Result<Void, NSError>.Callback) {}
    
    func cancelCardApplication(_ apiKey: String, userToken: String, applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {}
    
    func issueCard(_ apiKey: String, userToken: String, applicationId: String, additionalFields: [String : AnyObject]?, metadata: String?, design: IssueCardDesign?, callback: @escaping Result<Card, NSError>.Callback) {}
}
