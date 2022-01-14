//
//  VerifyPasscodeInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class VerifyPasscodeInteractorTest: XCTestCase {
    private var sut: VerifyPasscodeInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let authenticationManager = AuthenticationManagerFake()
    private let code = "1111"

    override func setUp() {
        super.setUp()

        sut = VerifyPasscodeInteractor(authenticationManager: authenticationManager)
    }

    func testVerifyCodeCallAuthManager() {
        // When
        sut.verify(code: code) { _ in }

        // Then
        XCTAssertTrue(authenticationManager.isValidCalled)
    }

    func testCodeIsValidCallbackTrue() {
        // Given
        authenticationManager.nextIsValidResult = true

        // When
        sut.verify(code: code) { result in
            // Then
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(true, result.value)
        }
    }

    func testCodeIsNotValidCallbackFalse() {
        // Given
        authenticationManager.nextIsValidResult = false

        // When
        sut.verify(code: code) { result in
            // Then
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(false, result.value)
        }
    }
}
