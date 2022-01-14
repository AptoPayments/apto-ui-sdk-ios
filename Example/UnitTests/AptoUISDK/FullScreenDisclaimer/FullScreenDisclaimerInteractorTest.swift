//
//  FullScreenDisclaimerInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class FullScreenDisclaimerInteractorTest: XCTestCase {
    private var sut: FullScreenDisclaimerInteractor!

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let disclaimer: Content = .plainText("Disclaimer")

    override func setUp() {
        super.setUp()

        sut = FullScreenDisclaimerInteractor(disclaimer: disclaimer)
    }

    func testProvideDisclaimerSetDisclaimerToDataReceiver() {
        // Given
        var returnedDisclaimer: Content?

        // When
        sut.provideDisclaimer { disc in
            returnedDisclaimer = disc
        }

        // Then
        XCTAssertEqual(disclaimer, returnedDisclaimer!) // swiftlint:disable:this implicitly_unwrapped_optional
    }
}
