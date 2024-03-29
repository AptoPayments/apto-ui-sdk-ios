//
//  CreatePasscodeInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class CreatePasscodeInteractorTest: XCTestCase {
    private var sut: CreatePasscodeInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let authenticationManager = AuthenticationManagerFake()
    private let code = "1111"

    override func setUp() {
        super.setUp()
        sut = CreatePasscodeInteractor(authenticationManager: authenticationManager)
    }

    func testSaveCallAuthenticationManager() {
        // When
        sut.save(code: code) { _ in }

        // Then
        XCTAssertTrue(authenticationManager.saveCalled)
        XCTAssertEqual(code, authenticationManager.lastSaveCode)
    }

    func testSaveCodeSucceedCallbackSuccess() {
        // Given
        authenticationManager.nextSaveResult = .success(())

        // When
        sut.save(code: code) { result in
            // Then
            XCTAssertTrue(result.isSuccess)
        }
    }

    func testSaveCodeFailsCallbackFailure() {
        // Given
        authenticationManager.nextSaveResult = .failure(BackendError(code: .other))

        // When
        sut.save(code: code) { result in
            // Then
            XCTAssertTrue(result.isFailure)
        }
    }
}
