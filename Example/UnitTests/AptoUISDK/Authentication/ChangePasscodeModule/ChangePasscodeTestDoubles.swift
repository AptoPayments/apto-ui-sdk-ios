//
//  ChangePasscodeTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//

import AptoSDK
@testable import AptoUISDK

class ChangePasscodeModuleSpy: UIModuleSpy, ChangePasscodeModuleProtocol {
  private(set) var showForgotPasscodeCalled = false
  func showForgotPasscode() {
    showForgotPasscodeCalled = true
  }
}

class ChangePasscodeInteractorSpy: ChangePasscodeInteractorProtocol {
  private(set) var verifyCodeCalled = false
  private(set) var lastVerifyCode: String?
  func verify(code: String, callback: @escaping Result<Bool, Never>.Callback) {
    verifyCodeCalled = true
    lastVerifyCode = code
  }

  private(set) var saveCodeCalled = false
  private(set) var lastSaveCode: String?
  func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    saveCodeCalled = true
    lastSaveCode = code
  }
}

class ChangePasscodeInteractorFake: ChangePasscodeInteractorSpy {
  var nextVerifyCodeResult: Result<Bool, Never>?
  override func verify(code: String, callback: @escaping Result<Bool, Never>.Callback) {
    super.verify(code: code, callback: callback)
    if let result = nextVerifyCodeResult {
      callback(result)
    }
  }

  var nextSaveCodeResult: Result<Void, NSError>?
  override func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    super.save(code: code, callback: callback)
    if let result = nextSaveCodeResult {
      callback(result)
    }
  }
}

class ChangePasscodePresenterSpy: ChangePasscodePresenterProtocol {
  var router: ChangePasscodeModuleProtocol?
  var interactor: ChangePasscodeInteractorProtocol?
  var analyticsManager: AnalyticsServiceProtocol?
  let viewModel = ChangePasscodeViewModel()

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var passcodeEnteredCalled = false
  private(set) var lastPasscodeEntered: String?
  func passcodeEntered(_ passcode: String) {
    passcodeEnteredCalled = true
    lastPasscodeEntered = passcode
  }

  private(set) var forgotPasscodeTappedCalled = false
  func forgotPasscodeTapped() {
    forgotPasscodeTappedCalled = true
  }
}
