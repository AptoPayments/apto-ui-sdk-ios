//
//  RemoteBankAccountLoaderTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 18/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import Alamofire
import SwiftyJSON
@testable import AptoSDK

class RemoteBankAccountLoaderTests: XCTestCase {

    private let apiKey = "api_key"
    private let userToken = "user_token"

    func test_init_doesNotRequestDataFromURL() {
        let (_, transport) = makeSUT()

        XCTAssertFalse(transport.getCalled)
        XCTAssertFalse(transport.postCalled)
        XCTAssertTrue(transport.requestesURLs.isEmpty)
    }
    
    // MARK: LoadBankAccount tests
    func test_loadBankAccount_requestDataFromURL() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .bankAccountDetails, parameters: [":balance_id": balanceId])

        sut.loadBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }
        
        XCTAssertTrue(transport.getCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }

    func test_loadBankAccountTwice_requestDataFromURLTwice() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .bankAccountDetails, parameters: [":balance_id": balanceId])
        
        sut.loadBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }
        sut.loadBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }

        XCTAssertTrue(transport.getCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()])
    }
    
    func test_loadBankAccount_deliversErrorOnClientErrors() {
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
    
    func test_loadBankAccount_deliversErrorOnInvalidJSONResponse() throws {
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

    func test_loadBankAccount_deliversAccountDetailsOnValidJSONResponse() throws {
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
    
    // MARK: AssignBankAccount tests
    func test_assignBankAccount_requestDataFromURL() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .assignBankAccount, parameters: [":balance_id": balanceId])

        sut.assignBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }
        
        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }

    func test_assignBankAccountTwice_requestDataFromURLTwice() throws {
        let balanceId = "1234567890"
        let (sut, transport) = makeSUT()
        let url = makeURLWrapper(transport, url: .assignBankAccount, parameters: [":balance_id": balanceId])
        
        sut.assignBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }
        sut.assignBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { _ in }

        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()])
    }

    func test_assignBankAccount_deliversErrorOnClientErrors() {
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

    func test_assignBankAccount_deliversErrorOnInvalidJSONResponse() throws {
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

    func test_assignBankAccount_deliversAccountDetailsOnValidJSONResponse() throws {
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
    private func makeSUT() -> (sut: BankAccountStorage, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let sut = BankAccountStorage(transport: transport)
        return (sut, transport)
    }
    
    private func makeURLWrapper(_ transport: JSONTransport, url: JSONRouter, parameters: [String: String]? = nil) -> URLWrapper {
        URLWrapper(baseUrl: transport.environment.baseUrl(), url: url, urlParameters: parameters)
    }
    
    private func expectLoad(_ sut: BankAccountStorage,
                            toCompleteWith result: BankAccountResult,
                            apiKey: String,
                            userToken: String,
                            balanceId: String,
                            when action: () -> Void) {
        
        var capturedResults = [BankAccountResult]()
        sut.loadBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { result in
            capturedResults.append(result)
        }

        action()
        
        XCTAssertEqual(capturedResults, [result])
    }
    
    private func expectAssign(_ sut: BankAccountStorage,
                              toCompleteWith result: BankAccountResult,
                              apiKey: String,
                              userToken: String,
                              balanceId: String,
                              when action: () -> Void) {
        
        var capturedResults = [BankAccountResult]()
        sut.assignBankAccount(apiKey, userToken: userToken, balanceId: balanceId) { result in
            capturedResults.append(result)
        }

        action()
        
        XCTAssertEqual(capturedResults, [result])
    }

    private func makeAccountDetails(routingNumber: String, accountNumber: String) -> (accountDetails: BankAccountDetails, json: JSON) {
        
        let details = BankAccountDetails(routingNumber: routingNumber, accountNumber: accountNumber)
        let jsonDetails: JSON = [
            "routing_number": routingNumber,
            "account_number": accountNumber
        ]
        
        return (details, jsonDetails)
    }    
}
