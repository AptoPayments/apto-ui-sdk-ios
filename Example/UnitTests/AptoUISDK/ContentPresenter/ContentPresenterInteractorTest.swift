//
//  ContentPresenterInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class ContentPresenterInteractorTest: XCTestCase {
    private var sut: ContentPresenterInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let content = Content.plainText("Content")

    override func setUp() {
        super.setUp()

        sut = ContentPresenterInteractor(content: content)
    }

    func testProvideContentReturnContent() {
        // Given
        var returnedContent: Content?

        // When
        sut.provideContent { content in
            returnedContent = content
        }

        // Then
        XCTAssertEqual(content, returnedContent)
    }
}
