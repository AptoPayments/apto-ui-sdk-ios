//
//  XCTestCase+AcceptDisclaimerSpecs.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 28/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import AptoSDK
import Foundation
import XCTest

extension CardApplicationSpecs where Self: XCTestCase {
    func assertThatAcceptDisclaimerPostDataToURL(on sut: CardApplicationsStorageProtocol,
                                                 transport: StorageTransportSpy,
                                                 workflowObject: WorkflowObject,
                                                 workflowAction: WorkflowAction,
                                                 file: StaticString = #filePath, line: UInt = #line)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.acceptDisclaimer)
        sut.acceptDisclaimer(apiKey(),
                             userToken: userToken(),
                             workflowObject: workflowObject,
                             workflowAction: workflowAction) { _ in }

        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()], file: file, line: line)
    }

    func assertThatAcceptDisclaimerPostDataToURLTwice(on sut: CardApplicationsStorageProtocol,
                                                      transport: StorageTransportSpy,
                                                      workflowObject: WorkflowObject,
                                                      workflowAction: WorkflowAction,
                                                      file: StaticString = #filePath, line: UInt = #line)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.acceptDisclaimer)
        sut.acceptDisclaimer(apiKey(),
                             userToken: userToken(),
                             workflowObject: workflowObject,
                             workflowAction: workflowAction) { _ in }
        sut.acceptDisclaimer(apiKey(),
                             userToken: userToken(),
                             workflowObject: workflowObject,
                             workflowAction: workflowAction) { _ in }

        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()], file: file, line: line)
    }

    func assertThatAcceptDisclaimerDeliversErrorOnClientErrors(on sut: CardApplicationsStorageProtocol,
                                                               transport: StorageTransportSpy,
                                                               workflowObject: WorkflowObject,
                                                               workflowAction: WorkflowAction,
                                                               file _: StaticString = #filePath, line _: UInt = #line)
    {
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectAcceptDisclaimer(sut,
                               toCompleteWith: .failure(clientError),
                               apiKey: apiKey(),
                               userToken: userToken(),
                               workflowObject: workflowObject,
                               workflowAction: workflowAction) {
            transport.complete(with: clientError)
        }
    }

    func assertThatAcceptDisclaimerDeliversNewApplicationOnValidJSONResponse(on sut: CardApplicationsStorageProtocol,
                                                                             transport: StorageTransportSpy,
                                                                             workflowObject: WorkflowObject,
                                                                             workflowAction: WorkflowAction,
                                                                             file _: StaticString = #filePath, line _: UInt = #line)
    {
        expectAcceptDisclaimer(sut,
                               toCompleteWith: .success(()),
                               apiKey: apiKey(),
                               userToken: userToken(),
                               workflowObject: workflowObject,
                               workflowAction: workflowAction) {
            transport.complete(withResult: [])
        }
    }
}

extension CardApplicationSpecs where Self: XCTestCase {
    func expectAcceptDisclaimer(_ sut: CardApplicationsStorageProtocol,
                                toCompleteWith result: Result<Void, NSError>,
                                apiKey: String,
                                userToken: String,
                                workflowObject: WorkflowObject,
                                workflowAction: WorkflowAction,
                                when action: () -> Void,
                                file: StaticString = #filePath, line: UInt = #line)
    {
        var receivedResult: (Result<Void, NSError>)?

        sut.acceptDisclaimer(apiKey,
                             userToken: userToken,
                             workflowObject: workflowObject,
                             workflowAction: workflowAction) { receivedResult = $0 }

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
