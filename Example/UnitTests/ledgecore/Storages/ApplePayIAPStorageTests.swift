//
//  ApplePayInAppProvisioningStorageTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 15/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import AptoSDK

class ApplePayIAPStorageTests: XCTestCase {

    private let apiKey = "api_key"
    private let userToken = "user_token"
    private let cardId = "crd_1234567890"

    func test_inAppProvisioning_requestsDataFromURL() {
        let (sut, transport) = makeSUT()
        let urlParameters = [":account_id": cardId]
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .applePayInAppProvisioning, urlParameters: urlParameters)
        
        sut.inAppProvisioning(apiKey, userToken: userToken, cardId: cardId, payload: makeInAppProvisioningInputData()) { _ in }
        
        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()])
    }
    
    func test_inAppProvisioningTwice_requestsDataFromURLTwice() {
        let (sut, transport) = makeSUT()
        let urlParameters = [":account_id": cardId]
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: .applePayInAppProvisioning, urlParameters: urlParameters)

        sut.inAppProvisioning(apiKey, userToken: userToken, cardId: cardId, payload: makeInAppProvisioningInputData()) { _ in }
        sut.inAppProvisioning(apiKey, userToken: userToken, cardId: cardId, payload: makeInAppProvisioningInputData()) { _ in }

        XCTAssertTrue(transport.postCalled)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()])
    }

    func test_inAppProvisioning_deliversErrorOnClientError() {
        let (sut, transport) = makeSUT()
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expect(sut,
               toCompleteWith: .failure(clientError),
               apiKey: apiKey,
               userToken: userToken,
               inputData: makeInAppProvisioningInputData()) {
            transport.complete(with: clientError)
        }
    }

    func test_inAppProvisioning_deliversErrorOnInvalidJSONResponse() throws {
        let (sut, transport) = makeSUT()
        let json = try JSON(data: Data("[]".utf8))

        expect(sut,
               toCompleteWith: .failure(ServiceError(code: .jsonError)),
               apiKey: apiKey,
               userToken: userToken,
               inputData: makeInAppProvisioningInputData()) {
            transport.complete(withResult: json)
        }
    }

    func test_inAppProvisioning_deliversApplePayIAPResultOnValidJSONResponse() throws {
        let (sut, transport) = makeSUT()
        let item = makeIAPResult()

        expect(sut,
               toCompleteWith: .success(item.issuerResponse),
               apiKey: apiKey,
               userToken: userToken,
               inputData: makeInAppProvisioningInputData()) {
            transport.complete(withResult: item.json)
        }
    }

    // MARK: Private Helper methods
    private func makeSUT() -> (sut: ApplePayIAPStorage, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let sut = ApplePayIAPStorage(transport: transport)
        return (sut, transport)
    }

    private func expect(_ sut: ApplePayIAPStorage,
                        toCompleteWith result: ApplePayIAPResult,
                        apiKey: String,
                        userToken: String,
                        inputData: ApplePayIAPInputData,
                        when action: () -> Void) {
        
        var capturedResults = [ApplePayIAPResult]()
        sut.inAppProvisioning(apiKey, userToken: userToken, cardId: cardId, payload: makeInAppProvisioningInputData()) { capturedResults.append($0) }

        action()
        
        XCTAssertEqual(capturedResults, [result])
    }
    
    private func makeIAPResult() -> (issuerResponse: ApplePayIAPIssuerResponse, json: JSON) {
        let iapResponse = ApplePayIAPIssuerResponse(encryptedPassData: anyData(),
                                                    activationData: anyData(),
                                                    ephemeralPublicKey: anyData())
        
        let json: JSON = [
            "encrypted_pass_data": "YW55IGRhdGE=",
            "activation_data": "YW55IGRhdGE=",
            "ephemeral_public_key": "YW55IGRhdGE="
        ]
        
        return (iapResponse, json)
    }
    
    private func makeInAppProvisioningInputData() -> ApplePayIAPInputData {
        ApplePayIAPInputData(certificates: [anyBase64EncodedString(), anyBase64EncodedString()], nonce: anyBase64EncodedString(), nonceSignature: anyBase64EncodedString())
    }
    
    private func anyData() -> Data {
        Data(base64Encoded: "YW55IGRhdGE=", options: [])!
    }

    private func anyString() -> String {
        "any string"
    }

    private func anyBase64EncodedString() -> String {
        "YW55IGRhdGE="
    }
}

class ApplePayIAPStorageSpy: ApplePayIAPStorageProtocol {
    func inAppProvisioning(_ apiKey: String, userToken: String, cardId: String, payload: ApplePayIAPInputData, completion: @escaping (ApplePayIAPResult) -> Void) {}
}
