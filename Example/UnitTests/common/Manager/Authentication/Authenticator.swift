//
//  Authenticator.swift
//  UnitTests
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

@testable import AptoUISDK

class AuthenticatorFake: AuthenticatorProtocol {
  private(set) var authenticateCalled = false
  var nextAuthenticateResult = true
  func authenticate(from: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
    authenticateCalled = true
    completion(nextAuthenticateResult)
  }
}
