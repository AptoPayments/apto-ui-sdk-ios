//
//  Authenticator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//

@testable import AptoUISDK

class AuthenticatorFake: AuthenticatorProtocol {
  var biometryType: BiometryType = .none
  var isBiometryAvailable = false

  private(set) var authenticateCalled = false
  private(set) var lastAuthenticationMode: AuthenticationMode?
  var nextAuthenticateResult = true
  func authenticate(from: UIModuleProtocol, mode: AuthenticationMode, completion: @escaping (Bool) -> Void) {
    authenticateCalled = true
    lastAuthenticationMode = mode
    completion(nextAuthenticateResult)
  }

  func resetSpies() {
    authenticateCalled = false
    lastAuthenticationMode = nil
  }
    
    func authenticateOnStartup(from: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func requestBiometricPermission(from: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
