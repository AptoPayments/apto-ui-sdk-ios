//
// WebBrowserInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/11/2018.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class WebBrowserInteractorTest: XCTestCase {
    var sut: WebBrowserInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    let dataReceiver = WebBrowserPresenterSpy()
    let url = ModelDataProvider.provider.url

    override func setUp() {
        super.setUp()

        sut = WebBrowserInteractor(url: url, dataReceiver: dataReceiver)
    }

    func testProvideUrlUpdateDataReceiver() {
        // When
        sut.provideUrl()

        // Then
        XCTAssertTrue(dataReceiver.loadUrlCalled)
        XCTAssertEqual(url, dataReceiver.lastUrlToLoad)
    }
}
