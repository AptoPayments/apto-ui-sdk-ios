//
//  P2PTransferStorageTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 17/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import AptoSDK
import Alamofire
import SwiftyJSON

class P2PTransferStorageTests: XCTestCase {
    private let apiKey = "api_key"
    private let userToken = "user_token"
    private let phoneCode = "+34"
    private let phoneNumber = "645345432"
    private let email = "obama@nasa.gov"

    func test_init_doesNotRequestDataFromURL() {
        let (_, transport) = makeSUT()

        XCTAssertFalse(transport.getCalled)
        XCTAssertFalse(transport.postCalled)
        XCTAssertTrue(transport.requestesURLs.isEmpty)
    }

    // MARK: GetRecipient tests
    func test_getRecipient_requestDataFromURL() throws {
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .p2pRecipient,
                                 parameters: ["email": email])

        sut.getRecipient(apiKey,
                         userToken: userToken,
                         phoneCode: nil,
                         phoneNumber: nil, email: email) { _ in }
        
        XCTAssertTrue(transport.getCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }

    func test_getRecipient_deliversErrorWithInvalidParameters() throws {
        let (sut, transport) = makeSUT()
        let clientError = ServiceError(code: .invalidRequestData)
        
        expectRecipient(sut,
                        toCompleteWith: .failure(clientError),
                        apiKey: apiKey,
                        userToken: userToken,
                        phoneCode: phoneCode,
                        phoneNumber: nil,
                        email: email) {
            transport.complete(with: clientError)
        }
    }

    func test_getRecipient_deliversErrorWithClientError() throws {
        let (sut, transport) = makeSUT()
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectRecipient(sut,
                        toCompleteWith: .failure(clientError),
                        apiKey: apiKey,
                        userToken: userToken,
                        phoneCode: phoneCode,
                        phoneNumber: nil,
                        email: email) {
            transport.complete(with: clientError)
        }
    }

    func test_getRecipient_deliversErrorOnInvalidJSONResponse() throws {
        let json = try JSON(data: Data("[]".utf8))
        let (sut, transport) = makeSUT()

        expectRecipient(sut,
                        toCompleteWith: .failure(ServiceError(code: .jsonError)),
                        apiKey: apiKey,
                        userToken: userToken,
                        phoneCode: phoneCode,
                        phoneNumber: nil,
                        email: email) {
            transport.complete(withResult: json)
        }
    }

    func test_getRecipient_deliversARecipientOnValidJSONResponse() throws {
        let (sut, transport) = makeSUT()
        let item = makeRecipient()
        
        expectRecipient(sut,
                        toCompleteWith: .success(item.recipient),
                        apiKey: apiKey,
                        userToken: userToken,
                        phoneCode: phoneCode,
                        phoneNumber: nil,
                        email: email) {
            transport.complete(withResult: item.json)
        }
    }

    // MARK: Transfer tests
    func test_transfer_deliversErrorWithClientError() {
        let (sut, transport) = makeSUT()
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)
        let request = P2PTransferRequest(sourceId: "1234567", recipientId: "12345555", amount: Amount(value: 10, currency: "USD"))
        
        expectTransfer(sut,
                       toCompleteWith: .failure(clientError),
                       apiKey: apiKey,
                       userToken: userToken,
                       transferRequest: request) {
            transport.complete(with: clientError)
        }
    }

    func test_transfer_deliversP2PTransferResultOnValidJSONResponse() {
        let (sut, transport) = makeSUT()
        let item = makeTransferResponse()

        let request = P2PTransferRequest(sourceId: "1234567", recipientId: "12345555", amount: Amount(value: 10, currency: "USD"))

        expectTransfer(sut,
                       toCompleteWith: .success(item.response),
                       apiKey: apiKey,
                       userToken: userToken,
                       transferRequest: request) {
            transport.complete(withResult: item.json)
        }
    }
    
    // MARK: Private Helper methods
    private func makeSUT() -> (sut: P2PTransferStorage, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let sut = P2PTransferStorage(transport: transport)
        return (sut, transport)
    }
    
    private func makeURLWrapper(_ transport: JSONTransport, url: JSONRouter, parameters: [String: String]? = nil) -> URLWrapper {
        URLWrapper(baseUrl: transport.environment.baseUrl(), url: url, urlParameters: parameters)
    }

    private func expectRecipient(_ sut: P2PTransferStorage,
                                 toCompleteWith result: P2PTransferRecipientResult,
                                 apiKey: String,
                                 userToken: String,
                                 phoneCode: String?,
                                 phoneNumber: String?,
                                 email: String?,
                                 with action: () -> Void) {
        var capturedResults = [P2PTransferRecipientResult]()
        sut.getRecipient(apiKey,
                         userToken: userToken,
                         phoneCode: nil,
                         phoneNumber: nil, email: email) { result in
            capturedResults.append(result)
        }

        action()
        
        XCTAssertEqual(capturedResults, [result])
    }
    
    private func expectTransfer(_ sut: P2PTransferStorage,
                                toCompleteWith result: P2PTransferResult,
                                apiKey: String,
                                userToken: String,
                                transferRequest: P2PTransferRequest,
                                with action: () -> Void) {
        var capturedResult = [P2PTransferResult]()
        sut.transfer(apiKey,
                     userToken: userToken,
                     transferRequest: transferRequest) { result in
            capturedResult.append(result)
        }
        
        action()
        
        XCTAssertEqual(capturedResult, [result])
    }
    
    private func makeRecipient() -> (recipient: CardholderData, json: JSON) {
        let details = CardholderData(firstName: "Ben", lastName: "Hur", cardholderId: "crdhlr_1234567890abcdef")
        let jsonDetails: JSON = [
            "name" : [
                "first_name": "Ben",
                "last_name": "Hur"
            ],
            "cardholder_id": "crdhlr_1234567890abcdef"
        ]
        return (details, jsonDetails)
    }
    
    private func makeTransferResponse() -> (response: P2PTransferResponse, json: JSON) {
        let date = Date.dateFromISO8601(string: "2016-10-19T23:20:17.000Z")
        let response = P2PTransferResponse(transferId: "balxfr_XXXXXXXXXXXXXXXX",
                                           status: PaymentResultStatus.processed,
                                           sourceId: "bal_XXXXXXXXXXXXXXXX",
                                           amount: Amount(value: 1457.87, currency: "USD"),
                                           recipientFirstName: "John",
                                           recipientLastName: "Smith",
                                           createdAt: date)

        let jsonDetails: JSON = [
            "id": "balxfr_XXXXXXXXXXXXXXXX",
            "status": "processed",
            "source_id": "bal_XXXXXXXXXXXXXXXX",
            "amount": [
                "currency": "USD",
                "amount": 1457.87
            ],
            "recipient": [
                "name": [
                    "first_name": "John",
                    "last_name": "Smith"
                ]
            ],
            "created_at": "2016-10-19T23:20:17.000Z"
        ]
        
        return (response, jsonDetails)
    }
}

class P2PTransferStorageSpy: P2PTransferProtocol {
    func getRecipient(_ apiKey: String, userToken: String, phoneCode: String?, phoneNumber: String?, email: String?, completion: @escaping (P2PTransferRecipientResult) -> Void) {
    }
    func inviteUser(_ apiKey: String, userToken: String, invitation: P2PInvite, completion: @escaping (P2PInviteResult) -> Void) {
    }
    func transfer(_ apiKey: String, userToken: String, transferRequest: P2PTransferRequest, completion: @escaping (P2PTransferResult) -> Void) {
    }
}

