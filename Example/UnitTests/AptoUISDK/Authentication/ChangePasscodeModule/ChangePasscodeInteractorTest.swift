//
//  ChangePasscodeInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 13/02/2020.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class ChangePasscodeInteractorTest: XCTestCase {
  private var sut: ChangePasscodeInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let authenticationManager = AuthenticationManagerFake()
  private let code = "1111"

  override func setUp() {
    super.setUp()

    sut = ChangePasscodeInteractor(authenticationManager: authenticationManager)
  }

  // MARK: - Verify code
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

  // MARK: - Save passcode
  func testSaveCallAuthenticationManager() {
    // When
    sut.save(code: code) { _ in }

    // Then
    XCTAssertTrue(authenticationManager.saveCalled)
    XCTAssertEqual(code, authenticationManager.lastSaveCode)
  }

  func testSaveCodeSucceedCallbackSuccess() {
    // Given
    authenticationManager.nextSaveResult = .success(Void())

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
