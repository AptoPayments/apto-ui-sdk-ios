//
//  XCTestCase+CreateApplicationSpecs.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import AptoSDK
import XCTest

extension CardApplicationSpecs where Self: XCTestCase {
    func assertThatCreateApplicationPostDataToURL(on sut: CardApplicationsStorageProtocol, transport: StorageTransportSpy, file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.applyToCard)

        sut.createApplication(apiKey(),
                              userToken: userToken(),
                              cardProduct: anyCardProduct()) { _ in }

        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL()], file: file, line: line)
    }
    
    func assertThatCreateApplicationPostDataToURLTwice(on sut: CardApplicationsStorageProtocol, transport: StorageTransportSpy, file: StaticString = #filePath, line: UInt = #line) {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(), url: JSONRouter.applyToCard)

        sut.createApplication(apiKey(),
                              userToken: userToken(),
                              cardProduct: anyCardProduct()) { _ in }
        sut.createApplication(apiKey(),
                              userToken: userToken(),
                              cardProduct: anyCardProduct()) { _ in }

        XCTAssertTrue(transport.postCalled, file: file, line: line)
        XCTAssertEqual(transport.requestesURLs, [try url.asURL(), try url.asURL()], file: file, line: line)
    }
    
    func assertThatCreateApplicationDeliversErrorOnClientErrors(on sut: CardApplicationsStorageProtocol, transport: StorageTransportSpy, file: StaticString = #filePath, line: UInt = #line) {
        let clientError = NSError(domain: "APTO DOMAIN ERROR", code: 0)

        expectCreateApplication(sut,
                                toCompleteWith: .failure(clientError),
                                apiKey: apiKey(),
                                userToken: userToken(),
                                cardProduct: anyCardProduct()) {
            transport.complete(with: clientError)
        }
    }
    
    func assertThatCreateApplicationDeliversNewApplicationOnValidJSONResponse(on sut: CardApplicationsStorageProtocol, transport: StorageTransportSpy, file: StaticString = #filePath, line: UInt = #line) {
        let item = makeCardApplication()
        
        var capturedResults = [Result<CardApplication, NSError>]()
        
        sut.createApplication(apiKey(),
                              userToken: userToken(),
                              cardProduct: anyCardProduct()) { capturedResults.append($0) }
        transport.complete(withResult: item.json)
        
        XCTAssertEqual(try capturedResults[0].get().id, anyCardId())
    }
}

extension CardApplicationSpecs where Self: XCTestCase {
    func expectCreateApplication(_ sut: CardApplicationsStorageProtocol,
                                 toCompleteWith result: Result<CardApplication, NSError>,
                                 apiKey: String,
                                 userToken: String,
                                 cardProduct: CardProduct,
                                 when action: () -> Void) {
        var capturedResults = [Result<CardApplication, NSError>]()
        sut.createApplication(apiKey,
                              userToken: userToken,
                              cardProduct: cardProduct) { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result])
    }
}
