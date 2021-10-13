//
// UserTokenStorageTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/08/2019.
//

import Foundation
@testable import AptoSDK

class UserTokenStorageSpy: UserTokenStorageProtocol {
  private(set) var setCurrentTokenCalled = false
  private(set) var lastSetCurrentToken: String?
  private(set) var lastSetCurrentTokenPrimaryCredential: DataPointType?
  private(set) var lastSetCurrentTokenSecondaryCredential: DataPointType?
  func setCurrent(token: String, withPrimaryCredential: DataPointType, andSecondaryCredential: DataPointType) {
    setCurrentTokenCalled = true
    lastSetCurrentToken = token
    lastSetCurrentTokenPrimaryCredential = withPrimaryCredential
    lastSetCurrentTokenSecondaryCredential = andSecondaryCredential
  }

  private(set) var currentTokenCalled = false
  func currentToken() -> String? {
    currentTokenCalled = true
    return nil
  }

  private(set) var currentTokenPrimaryCredentialCalled = false
  func currentTokenPrimaryCredential() -> DataPointType? {
    currentTokenPrimaryCredentialCalled = true
    return nil
  }

  private(set) var currentTokenSecondaryCredentialCalled = false
  func currentTokenSecondaryCredential() -> DataPointType? {
    currentTokenSecondaryCredentialCalled = true
    return nil
  }

  private(set) var clearCurrentTokenCalled = false
  func clearCurrentToken() {
    clearCurrentTokenCalled = true
  }
}

class UserTokenStorageFake: UserTokenStorageSpy {
  private(set) var token: String?
  private(set) var primaryCredential: DataPointType?
  private(set) var secondaryCredential: DataPointType?

  override func setCurrent(token: String, withPrimaryCredential: DataPointType, andSecondaryCredential: DataPointType) {
    super.setCurrent(token: token, withPrimaryCredential: withPrimaryCredential,
                     andSecondaryCredential: andSecondaryCredential)
    self.token = token
    self.primaryCredential = withPrimaryCredential
    self.secondaryCredential = andSecondaryCredential
  }

  override func currentToken() -> String? {
    _ = super.currentToken()
    return token
  }

  override func currentTokenPrimaryCredential() -> DataPointType? {
    _ = super.currentTokenPrimaryCredential()
    return primaryCredential
  }

  override func currentTokenSecondaryCredential() -> DataPointType? {
    _ = super.currentTokenSecondaryCredential()
    return secondaryCredential
  }

  override func clearCurrentToken() {
    super.clearCurrentToken()
    token = nil
    primaryCredential = nil
    secondaryCredential = nil
  }
}
