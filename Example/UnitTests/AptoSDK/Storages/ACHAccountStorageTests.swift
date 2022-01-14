//
//  RemoteACHAccountLoaderTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 18/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Alamofire
@testable import AptoSDK
import SwiftyJSON
import XCTest

class RemoteACHAccountLoaderTests: XCTestCase {
    private let apiKey = "api_key"
    private let userToken = "user_token"

    func test_init_doesNotRequestDataFromURL() {
        let (_, transport) = makeSUT()

        XCTAssertFalse(transport.getCalled)
        XCTAssertFalse(transport.postCalled)
        XCTAssertTrue(transport.requestesURLs.isEmpty)
    }

    // MARK: LoadACHAccount tests

    func test_loadACHAccount_requestDataFromURL() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .achAccountDetails, parameters: [":balance_id": balanceId])

        sut.loadACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }

        XCTAssertTrue(transport.getCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }

    func test_loadACHAccountTwice_requestDataFromURLTwice() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .achAccountDetails, parameters: [":balance_id": balanceId])

        sut.loadACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }
        sut.loadACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }

        XCTAssertTrue(transport.getCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()])
    }

    func test_loadACHAccount_deliversErrorOnClientErrors() {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectLoad(sut,
                   toCompleteWith: .failure(clientError),
                   apiKey: apiKey,
                   userToken: userToken,
                   balanceId: balanceId) {
            transport.complete(with: clientError)
        }
    }

    func test_loadACHAccount_deliversErrorOnInvalidJSONResponse() throws {
        let balanceId = "1234567890"
        let json = try JSON(data: Data("[]".utf8))
        let (sut, transport) = makeSUT()

        expectLoad(sut,
                   toCompleteWith: .failure(ServiceError(code: .jsonError)),
                   apiKey: apiKey,
                   userToken: userToken,
                   balanceId: balanceId,
                   when: {
                       transport.complete(withResult: json)
                   })
    }

    func test_loadACHAccount_deliversAccountDetailsOnValidJSONResponse() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let item = makeAccountDetails(routingNumber: "123000789", accountNumber: "1234567890")

        expectLoad(sut,
                   toCompleteWith: .success(item.accountDetails),
                   apiKey: apiKey,
                   userToken: userToken,
                   balanceId: balanceId,
                   when: {
                       transport.complete(withResult: item.json)
                   })
    }

    // MARK: AssignACHAccount tests

    func test_assignACHAccount_requestDataFromURL() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .assignACHAccount, parameters: [":balance_id": balanceId])

        sut.assignACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }

        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }

    func test_assignACHAccountTwice_requestDataFromURLTwice() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .assignACHAccount, parameters: [":balance_id": balanceId])

        sut.assignACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }
        sut.assignACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }

        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()])
    }

    func test_assignACHAccount_deliversErrorOnClientErrors() {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectAssign(sut,
                     toCompleteWith: .failure(clientError),
                     apiKey: apiKey,
                     userToken: userToken,
                     balanceId: balanceId) {
            transport.complete(with: clientError)
        }
    }

    func test_assignACHAccount_deliversErrorOnInvalidJSONResponse() throws {
        let balanceId = "1234567890"
        let json = try JSON(data: Data("[]".utf8))
        let (sut, transport) = makeSUT()

        expectAssign(sut,
                     toCompleteWith: .failure(ServiceError(code: .jsonError)),
                     apiKey: apiKey,
                     userToken: userToken,
                     balanceId: balanceId,
                     when: {
                         transport.complete(withResult: json)
                     })
    }

    func test_assignACHAccount_deliversAccountDetailsOnValidJSONResponse() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let item = makeAccountDetails(routingNumber: "123000789", accountNumber: "1234567890")

        expectAssign(sut,
                     toCompleteWith: .success(item.accountDetails),
                     apiKey: apiKey,
                     userToken: userToken,
                     balanceId: balanceId,
                     when: {
                         transport.complete(withResult: item.json)
                     })
    }

    // MARK: Private Helper methods

    private func makeSUT() -> (sut: ACHAccountStorage, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let sut = ACHAccountStorage(transport: transport)
        return (sut, transport)
    }

    private func makeURLWrapper(_ transport: JSONTransport, url: JSONRouter, parameters: [String: String]? = nil) -> URLWrapper {
        URLWrapper(baseUrl: transport.environment.baseUrl(), url: url, urlParameters: parameters)
    }

    private func expectLoad(_ sut: ACHAccountStorage,
                            toCompleteWith result: ACHAccountResult,
                            apiKey: String,
                            userToken: String,
                            balanceId: String,
                            when action: () -> Void)
    {
        var capturedResults = [ACHAccountResult]()
        sut.loadACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { result in
            capturedResults.append(result)
        }

        action()

        XCTAssertEqual(capturedResults, [result])
    }

    private func expectAssign(_ sut: ACHAccountStorage,
                              toCompleteWith result: ACHAccountResult,
                              apiKey: String,
                              userToken: String,
                              balanceId: String,
                              when action: () -> Void)
    {
        var capturedResults = [ACHAccountResult]()
        sut.assignACHAccount(apiKey, userToken: userToken, balanceId: balanceId) { result in
            capturedResults.append(result)
        }

        action()

        XCTAssertEqual(capturedResults, [result])
    }

    private func makeAccountDetails(routingNumber: String, accountNumber: String) -> (accountDetails: ACHAccountDetails, json: JSON) {
        let details = ACHAccountDetails(routingNumber: routingNumber, accountNumber: accountNumber)
        let jsonDetails: JSON = [
            "account_details": [
                "routing_number": routingNumber,
                "account_number": accountNumber,
            ],
        ]

        return (details, jsonDetails)
    }
}

class ACHAccountStorageSpy: ACHAccountStorageProtocol {
    func loadACHAccount(_: String, userToken _: String, balanceId _: String, completion _: @escaping (ACHAccountResult) -> Void) {}

    func assignACHAccount(_: String, userToken _: String, balanceId _: String, completion _: @escaping (ACHAccountResult) -> Void) {}
}
