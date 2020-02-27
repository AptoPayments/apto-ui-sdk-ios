//
//  ChangePasscodeInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 13/02/2020.
//

class ChangePasscodeInteractor: ChangePasscodeInteractorProtocol {
  private let authenticationManager: AuthenticationManagerProtocol

  init(authenticationManager: AuthenticationManagerProtocol) {
    self.authenticationManager = authenticationManager
  }

  func verify(code: String, callback: @escaping Result<Bool, Never>.Callback) {
    let isValid = authenticationManager.isValid(code: code)
    callback(.success(isValid))
  }

  func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    let result = authenticationManager.save(code: code)
    callback(result)
  }
}
