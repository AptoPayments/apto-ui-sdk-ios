//
//  XCTestCase+IssueCardSpecs.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import AptoSDK
import XCTest

extension CardApplicationSpecs where Self: XCTestCase {
    func assertThatInitDoesNotRequestDataFromURL(on transport: StorageTransportSpy,
                                                 file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(transport.getCalled, file: file, line: line)
        XCTAssertFalse(transport.postCalled, file: file, line: line)
        XCTAssertTrue(transport.requestesURLs.isEmpty, file: file, line: line)
    }
    
    func assertThatIssueCardPostDataToURL(on sut: CardApplicationsStorageProtocol,
                                          transport: StorageTransportSpy,
                                          applicationId: String,
                                          metadata: String,
                                          design: IssueCardDesign,
                                          file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.issueCard)

        sut.issueCard(apiKey(),
                      userToken: userToken(),
                      applicationId: applicationId,
                      metadata: metadata,
                      design: design) { _ in }
        
        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()], file: file, line: line)
    }
    
    func assertThatIssueCardTwicePostDataToURLTwice(on sut: CardApplicationsStorageProtocol,
                                                    transport: StorageTransportSpy,
                                                    applicationId: String,
                                                    metadata: String,
                                                    design: IssueCardDesign,
                                                    file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.issueCard)

        sut.issueCard(apiKey(),
                      userToken: userToken(),
                      applicationId: applicationId,
                      metadata: metadata,
                      design: design) { _ in }
        sut.issueCard(apiKey(),
                      userToken: userToken(),
                      applicationId: applicationId,
                      metadata: metadata,
                      design: design) { _ in }

        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()], file: file, line: line)
    }
    
    func assertThatIssueCardDeliversErrorOnClientErrors(on sut: CardApplicationsStorageProtocol,
                                                        transport: StorageTransportSpy,
                                                        applicationId: String,
                                                        metadata: String,
                                                        design: IssueCardDesign,
                                                        file: StaticString = #filePath, line: UInt = #line) {
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectIssueCard(sut,
                        toCompleteWith: .failure(clientError),
                        apiKey: apiKey(),
                        userToken: userToken(),
                        applicationId: applicationId,
                        metadata: metadata,
                        design: design) {
            transport.complete(with: clientError)
        }
    }
    
    func asserThatIssueCardDeliversNewCardOnValidJSONResponse(on sut: CardApplicationsStorageProtocol,
                                                              transport: StorageTransportSpy,
                                                              applicationId: String,
                                                              metadata: String,
                                                              design: IssueCardDesign,
                                                              file: StaticString = #filePath, line: UInt = #line) {
        let item = makeIssueCard()
        
        expectIssueCard(sut,
                        toCompleteWith: .success(item.cardDetail),
                        apiKey: apiKey(),
                        userToken: userToken(),
                        applicationId: applicationId,
                        metadata: metadata,
                        design: design) {
            transport.complete(withResult: item.json)
        }
    }
}

extension CardApplicationSpecs where Self: XCTestCase {
    func expectIssueCard(_ sut: CardApplicationsStorageProtocol,
                         toCompleteWith result: Result<Card, NSError>,
                         apiKey: String,
                         userToken: String,
                         applicationId: String,
                         metadata: String?,
                         design: IssueCardDesign?,
                         when action: () -> Void,
                         file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [Result<Card, NSError>]()
        sut.issueCard(apiKey,
                      userToken: userToken,
                      applicationId: applicationId,
                      metadata: metadata,
                      design: design) { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults , [result], file: file, line: line)
    }
}
