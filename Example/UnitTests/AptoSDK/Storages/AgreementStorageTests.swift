//
//  AgreementStorageTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 22/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import AptoSDK

class AgreementStorageTests: XCTestCase {

    private let apiKey = "api_key"
    private let userToken = "user_token"

    func test_init_doesNotRequestDataFromURL() {
        let (_, transport) = makeSUT()

        XCTAssertFalse(transport.postCalled)
        XCTAssertTrue(transport.requestesURLs.isEmpty)
    }

    func test_recordAgreement_requestDataFromURL() throws {
        let (sut, transport) = makeSUT()
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .recordAgreementAction)
        let request = AgreementRequest(key: ["apto_cha", "apto_privacy"], userAction: .accepted)

        sut.recordAgreement(apiKey, userToken: userToken, agreementRequest: request) { _ in }
        
        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }

    func test_recordAgreementTwice_requestDataFromURLTwice() throws {
        let (sut, transport) = makeSUT()
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .recordAgreementAction)
        let request = AgreementRequest(key: ["apto_cha", "apto_privacy"], userAction: .accepted)

        sut.recordAgreement(apiKey, userToken: userToken, agreementRequest: request) { _ in }
        sut.recordAgreement(apiKey, userToken: userToken, agreementRequest: request) { _ in }

        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()])
    }

    func test_recordAgreement_deliversErrorOnClientErrors() throws {
        let (sut, transport) = makeSUT()
        let request = AgreementRequest(key: ["apto_cha", "apto_privacy"], userAction: .accepted)
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expect(sut,
               toCompleteWith: .failure(clientError),
               apiKey: apiKey,
               userToken: userToken,
               agreementRequest: request,
               when: {
                transport.complete(with: clientError)
               })
    }

    func test_recordAgreement_deliversErrorOnInvalidJSONResponse() throws {
        let (sut, transport) = makeSUT()
        let request = AgreementRequest(key: ["apto_cha", "apto_privacy"], userAction: .accepted)
        let json = try JSON(data: Data("[]".utf8))

        expect(sut,
               toCompleteWith: .failure(ServiceError(code: .jsonError)),
               apiKey: apiKey,
               userToken: userToken,
               agreementRequest: request,
               when: {
                transport.complete(withResult: json)
               })
    }

    func test_recordAgreement_deliversUserAgreementsOnValidJSONResponse() throws {
        let (sut, transport) = makeSUT()
        let request = AgreementRequest(key: ["apto_cha", "apto_privacy"], userAction: .accepted)
        let item = makeUserAgreements()

        expect(sut,
               toCompleteWith: .success(item.userAgreements),
               apiKey: apiKey,
               userToken: userToken,
               agreementRequest: request,
               when: {
                transport.complete(withResult: item.json)
               })
    }

    // MARK: Private Helper methods
    private func makeSUT() -> (sut: AgreementStorage, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let sut = AgreementStorage(transport: transport)
        return (sut, transport)
    }

    private func expect(_ sut: AgreementStorage,
                        toCompleteWith result: RecordedAgreementsResult,
                        apiKey: String,
                        userToken: String,
                        agreementRequest: AgreementRequest,
                        when action: () -> Void) {
        
        var capturedResults = [RecordedAgreementsResult]()
        sut.recordAgreement(apiKey,
                            userToken: userToken,
                            agreementRequest: agreementRequest) {  capturedResults.append($0) }

        action()
        
        XCTAssertEqual(capturedResults, [result])
    }

    private func makeUserAgreements() -> (userAgreements: [AgreementDetail], json: JSON) {
        
        let detail1 = AgreementDetail(idStr: "agreement_629adb2cc537cdf9",
                                      agreementKey: "evolve_eua",
                                      userAction: .accepted,
                                      actionRecordedAt: Date.dateFromISO8601(string: "2020-11-20T01:56:24.543-05:00"))

        let detail2 = AgreementDetail(idStr: "agreement_629adb2cc537cdff",
                                      agreementKey: "apto_privacy",
                                      userAction: .declined,
                                      actionRecordedAt: Date.dateFromISO8601(string: "2020-11-22T01:56:24.543-05:00"))

        let json1: JSON = [
            "user_agreement": [
                "id": "agreement_629adb2cc537cdf9",
                "agreement_key": "evolve_eua",
                "action": "ACCEPTED",
                "recorded_at": "2020-11-20T01:56:24.543-05:00"
            ]
        ]

        let json2: JSON = [
            "user_agreement": [
                "id": "agreement_629adb2cc537cdff",
                "agreement_key": "apto_privacy",
                "action": "DECLINED",
                "recorded_at": "2020-11-22T01:56:24.543-05:00"
            ]
        ]

        let json: JSON = ["user_agreements": [json1.object, json2.object]]
        
        let agreements = [detail1, detail2]
        
        return (agreements, json)
    }

}

class AgreementStorageSpy: AgreementStorageProtocol {
    func recordAgreement(_ apiKey: String, userToken: String, agreementRequest: AgreementRequest, completion: @escaping (RecordedAgreementsResult) -> Void) {
        
    }
}
