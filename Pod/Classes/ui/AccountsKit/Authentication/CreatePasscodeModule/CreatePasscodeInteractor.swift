//
// CreatePasscodeInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 21/11/2019.
//

import Foundation

class CreatePasscodeInteractor: CreatePasscodeInteractorProtocol {
  private let authenticationManager: AuthenticationManagerProtocol

  init(authenticationManager: AuthenticationManagerProtocol) {
    self.authenticationManager = authenticationManager
  }

  func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    let result = authenticationManager.save(code: code)
    callback(result)
  }
}
