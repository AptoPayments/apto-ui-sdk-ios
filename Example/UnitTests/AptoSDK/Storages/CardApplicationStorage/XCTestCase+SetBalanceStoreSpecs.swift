//
//  XCTestCase+SetBalanceStoreSpecs.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 27/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import AptoSDK
import Foundation
import XCTest

extension CardApplicationSpecs where Self: XCTestCase {
    func assertThatSetBalanceStorePostDataToURL(on sut: CardApplicationsStorageProtocol,
                                                transport: StorageTransportSpy,
                                                applicationId: String,
                                                custodian: Custodian = ModelDataProvider.provider.custodian,
                                                file: StaticString = #filePath, line: UInt = #line)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                             url: JSONRouter.setBalanceStore,
                             urlParameters: [":applicationId": applicationId])

        sut.setBalanceStore(apiKey(),
                            userToken: userToken(),
                            applicationId: applicationId,
                            custodian: custodian) { _ in }

        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()], file: file, line: line)
    }

    func assertThatSetBalanceStorePostDataToURLTwice(on sut: CardApplicationsStorageProtocol,
                                                     transport: StorageTransportSpy,
                                                     applicationId: String,
                                                     custodian: Custodian = ModelDataProvider.provider.custodian,
                                                     file: StaticString = #filePath, line: UInt = #line)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                             url: JSONRouter.setBalanceStore,
                             urlParameters: [":applicationId": applicationId])

        sut.setBalanceStore(apiKey(),
                            userToken: userToken(),
                            applicationId: applicationId,
                            custodian: custodian) { _ in }
        sut.setBalanceStore(apiKey(),
                            userToken: userToken(),
                            applicationId: applicationId,
                            custodian: custodian) { _ in }

        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()], file: file, line: line)
    }

    func assertThatSetBalanceStoreDeliversErrorOnClientErrors(on sut: CardApplicationsStorageProtocol,
                                                              transport: StorageTransportSpy,
                                                              applicationId: String,
                                                              custodian: Custodian = ModelDataProvider.provider.custodian,
                                                              file _: StaticString = #filePath, line _: UInt = #line)
    {
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectSetBalanceStore(sut,
                              toCompleteWith: .failure(clientError),
                              apiKey: apiKey(),
                              userToken: userToken(),
                              applicationId: applicationId,
                              custodian: custodian) {
            transport.complete(with: clientError)
        }
    }

    func assertThatSetBalanceStoreDeliversSelectBalanceStoreResultOnValidJSONResponse(on sut: CardApplicationsStorageProtocol,
                                                                                      transport: StorageTransportSpy,
                                                                                      applicationId: String,
                                                                                      custodian _: Custodian = ModelDataProvider.provider.custodian,
                                                                                      file _: StaticString = #filePath, line _: UInt = #line)
    {
        let item = makeSelectBalanceStoreResult()

        expectSetBalanceStore(sut,
                              toCompleteWith: .success(item.selectBalance),
                              apiKey: apiKey(),
                              userToken: userToken(),
                              applicationId: applicationId) {
            transport.complete(withResult: item.json)
        }
    }
}

extension CardApplicationSpecs where Self: XCTestCase {
    func expectSetBalanceStore(_ sut: CardApplicationsStorageProtocol,
                               toCompleteWith result: Result<SelectBalanceStoreResult, NSError>,
                               apiKey: String,
                               userToken: String,
                               applicationId: String,
                               custodian: Custodian = ModelDataProvider.provider.custodian,
                               when action: () -> Void,
                               file: StaticString = #filePath, line: UInt = #line)
    {
        var capturedResults = [Result<SelectBalanceStoreResult, NSError>]()
        sut.setBalanceStore(apiKey,
                            userToken: userToken,
                            applicationId: applicationId,
                            custodian: custodian) { capturedResults.append($0) }

        action()

        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
}
