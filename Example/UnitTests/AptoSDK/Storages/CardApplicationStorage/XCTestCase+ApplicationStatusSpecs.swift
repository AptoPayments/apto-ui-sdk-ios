//
//  XCTestCase+ApplicationStatusSpecs.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 27/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import AptoSDK

extension CardApplicationSpecs where Self: XCTestCase {
    func assertThatApplicationStatusGetDataFromURL(on sut: CardApplicationsStorageProtocol,
                                                   transport: StorageTransportSpy,
                                                   applicationId: String,
                                                   file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.cardApplicationStatus,
                             urlParameters: [":applicationId": applicationId])
        sut.applicationStatus(apiKey(),
                              userToken: userToken(),
                              applicationId: applicationId) { _ in }
        XCTAssertTrue(transport.getCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()], file: file, line: line)
    }
    
    func assertThatApplicationStatusTwiceGetDataToURLTwice(on sut: CardApplicationsStorageProtocol,
                                                           transport: StorageTransportSpy,
                                                           applicationId: String,
                                                           file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.cardApplicationStatus,
                             urlParameters: [":applicationId": applicationId])
        sut.applicationStatus(apiKey(),
                              userToken: userToken(),
                              applicationId: applicationId) { _ in }
        sut.applicationStatus(apiKey(),
                              userToken: userToken(),
                              applicationId: applicationId) { _ in }
        XCTAssertTrue(transport.getCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()], file: file, line: line)
    }
    
    func assertThatApplicationStatusDeliversErrorOnClientErrors(on sut: CardApplicationsStorageProtocol,
                                                                transport: StorageTransportSpy,
                                                                applicationId: String,
                                                                file: StaticString = #filePath, line: UInt = #line) {
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)
        
        expectApplicationStatus(sut,
                                toCompleteWith: .failure(clientError),
                                apiKey: apiKey(),
                                userToken: userToken(),
                                applicationId: applicationId) {
            transport.complete(with: clientError)
        }
    }
    
    func assertThatApplicationStatusDeliversApplicationOnValidJSONResponse(on sut: CardApplicationsStorageProtocol,
                                                                           transport: StorageTransportSpy,
                                                                           applicationId: String,
                                                                           file: StaticString = #filePath, line: UInt = #line) {
        let item = makeCardApplication()

        expectApplicationStatus(sut,
                                toCompleteWith: .success(item.cardApplication),
                                apiKey: apiKey(),
                                userToken: userToken(),
                                applicationId: applicationId) {
            transport.complete(withResult: item.json)
        }
    }
}

extension CardApplicationSpecs where Self: XCTestCase {
    func expectApplicationStatus(_ sut: CardApplicationsStorageProtocol,
                                 toCompleteWith result: Result<CardApplication, NSError>,
                                 apiKey: String,
                                 userToken: String,
                                 applicationId: String,
                                 when action: () -> Void,
                                 file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [Result<CardApplication, NSError>]()
        sut.applicationStatus(apiKey,
                              userToken: userToken,
                              applicationId: applicationId) { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults , [result], file: file, line: line)
    }
}
