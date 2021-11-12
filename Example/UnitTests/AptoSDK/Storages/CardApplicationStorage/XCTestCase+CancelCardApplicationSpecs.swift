//
//  XCTestCase+CancelCardApplicationSpecs.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 28/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import AptoSDK
import XCTest

extension CardApplicationSpecs where Self: XCTestCase {
    func assertThatCancelCardApplicationDeleteDataFromURL(on sut: CardApplicationsStorageProtocol,
                                                          transport: StorageTransportSpy,
                                                          applicationId: String,
                                                          file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.cardApplication, urlParameters: [":applicationId": applicationId])
        sut.cancelCardApplication(apiKey(),
                                  userToken: userToken(),
                                  applicationId: applicationId) { _ in }
        XCTAssertTrue(transport.deleteCalled, file: file, line: line)
        XCTAssertEqual(transport.voidRequestesURLs, [try url.asURL()], file: file, line: line)
    }
    
    func assertThatCancelCardApplicationDeleteDataFromURLTwice(on sut: CardApplicationsStorageProtocol,
                                                               transport: StorageTransportSpy,
                                                               applicationId: String,
                                                               file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.cardApplication, urlParameters: [":applicationId": applicationId])
        sut.cancelCardApplication(apiKey(),
                                  userToken: userToken(),
                                  applicationId: applicationId) { _ in }

        sut.cancelCardApplication(apiKey(),
                                  userToken: userToken(),
                                  applicationId: applicationId) { _ in }

        XCTAssertTrue(transport.deleteCalled, file: file, line: line)
        XCTAssertEqual(transport.voidRequestesURLs, [try url.asURL(), try url.asURL()], file: file, line: line)
    }
    
    func assertThatCancelCardApplicationDeliversErrorOnClientErrors(on sut: CardApplicationsStorageProtocol,
                                                                    transport: StorageTransportSpy,
                                                                    applicationId: String,
                                                                    file: StaticString = #filePath, line: UInt = #line) {
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)
        
        expectCancelCardApplication(sut,
                                    toCompleteWith: .failure(clientError),
                                    apiKey: apiKey(),
                                    userToken: userToken(),
                                    applicationId: applicationId) {
            transport.completeVoid(with: clientError)
        }
    }
    
    func assertThatCancelCardApplicationDeliversNewApplicationOnValidJSONResponse(on sut: CardApplicationsStorageProtocol,
                                                                                  transport: StorageTransportSpy,
                                                                                  applicationId: String,
                                                                                  file: StaticString = #filePath, line: UInt = #line) {
        expectCancelCardApplication(sut,
                                    toCompleteWith: .success(()),
                                    apiKey: apiKey(),
                                    userToken: userToken(),
                                    applicationId: applicationId) {
            transport.completeVoid()
        }
        
    }
}

extension CardApplicationSpecs where Self: XCTestCase {
    func expectCancelCardApplication(_ sut: CardApplicationsStorageProtocol,
                                     toCompleteWith result: Result<Void, NSError>,
                                     apiKey: String,
                                     userToken: String,
                                     applicationId: String,
                                     when action: () -> Void,
                                     file: StaticString = #filePath, line: UInt = #line) {

        var receivedResult: (Result<Void, NSError>)?

        sut.cancelCardApplication(apiKey,
                                  userToken: userToken,
                                  applicationId: applicationId) { receivedResult = $0 }
        
        action()
        
        switch (receivedResult, result) {
        case (.success, .success):
            XCTAssertTrue(true, file: file, line: line)
            
        case let (.failure(expectedError), .failure(resultError)):
            XCTAssertEqual(expectedError, resultError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(result), got \(String(describing: receivedResult)) instead", file: file, line: line)
        }
    }
}
