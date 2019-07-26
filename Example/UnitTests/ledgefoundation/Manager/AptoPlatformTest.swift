//
// AptoPlatformTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 11/07/2019.
//

import XCTest
@testable import AptoSDK

class AptoPlatformTest: XCTestCase {
  private var sut = AptoPlatform.defaultManager()

  // Collaborators
  private let delegate = AptoPlatformDelegateSpy()
  private let apiKey = "api_key"
  private let environment = AptoPlatformEnvironment.production
  private let setupCertPinning = true

  override func setUp() {
    super.setUp()
    sut.delegate = delegate
  }

  func testInitializeWithApiKeyEnvironmentSetupCertPinningInitializeSDK() {
    // When
    sut.initializeWithApiKey(apiKey, environment: environment, setupCertPinning: setupCertPinning)

    // Then
    XCTAssertEqual(apiKey, sut.apiKey)
    XCTAssertEqual(environment, sut.environment)
    XCTAssertTrue(sut.initialized)
  }

  func testInitializeWithApiKeySetEnvironmentToSandbox() {
    // When
    sut.initializeWithApiKey(apiKey)

    // Then
    XCTAssertEqual(AptoPlatformEnvironment.production, sut.environment)
  }

  func testInitializeNotifyDelegate() {
    // When
    sut.initializeWithApiKey(apiKey)

    // Then
    XCTAssertTrue(delegate.sdkInitializedCalled)
    XCTAssertEqual(apiKey, delegate.lastApiKeyReceived)
  }
}

private class AptoPlatformDelegateSpy: AptoPlatformDelegate {
  private(set) var newUserTokenReceivedCalled = false
  private(set) var lastUserTokenReceived: String?
  func newUserTokenReceived(_ userToken: String?) {
    newUserTokenReceivedCalled = true
    lastUserTokenReceived = userToken
  }

  private(set) var sdkInitializedCalled = false
  private(set) var lastApiKeyReceived: String?
  func sdkInitialized(apiKey: String) {
    sdkInitializedCalled = true
    lastApiKeyReceived = apiKey
  }

  private(set) var sdkDeprecatedCalled = false
  func sdkDeprecated() {
    sdkDeprecatedCalled = true
  }
}
