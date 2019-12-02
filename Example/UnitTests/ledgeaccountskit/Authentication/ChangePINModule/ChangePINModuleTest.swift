//
//  ChangePINModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//

import XCTest
@testable import AptoUISDK

class ChangePINModuleTest: XCTestCase {
  private var sut: ChangePINModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()

  override func setUp() {
    super.setUp()

    sut = ChangePINModule(serviceLocator: serviceLocator)
  }

  func testInitializeStartPINVerification() {
    // Given
    let verifyPINModule = serviceLocator.moduleLocatorFake.verifyPINModuleSpy

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertTrue(verifyPINModule.initializeCalled)
  }

  func testPINVerificationFinishCreateNewPIN() {
    // Given
    let verifyPINModule = givenVerifyPINShown()
    let createPINModule = serviceLocator.moduleLocatorFake.createPINModuleSpy

    // When
    verifyPINModule.finish()

    // Then
    XCTAssertTrue(createPINModule.initializeCalled)
  }

  func testPINCreateCallFinish() {
    // Given
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }
    let createPINModule = givenCreatePINShown()

    // When
    createPINModule.finish()

    // Then
    XCTAssertTrue(onFinishCalled)
  }

  // MARK: - Helpers
  func givenVerifyPINShown() -> VerifyPINModuleSpy {
    let verifyPINModule = serviceLocator.moduleLocatorFake.verifyPINModuleSpy
    sut.initialize { _ in }
    return verifyPINModule
  }

  func givenCreatePINShown() -> CreatePINModuleSpy {
    let verifyPINModule = givenVerifyPINShown()
    let createPINModule = serviceLocator.moduleLocatorFake.createPINModuleSpy
    verifyPINModule.finish()
    return createPINModule
  }
}
