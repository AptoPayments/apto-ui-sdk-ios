//
//  VerifyPINTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

@testable import AptoSDK
@testable import AptoUISDK

class VerifyPINModuleSpy: UIModuleSpy, VerifyPINModuleProtocol {
  private(set) var showForgotPINCalled = false
  func showForgotPIN() {
    showForgotPINCalled = true
  }
}

class VerifyPINInteractorSpy: VerifyPINInteractorProtocol {
  private(set) var verifyCodeCalled = false
  private(set) var lastVerifyCode: String?
  func verify(code: String, callback: @escaping Result<Bool, Never>.Callback) {
    verifyCodeCalled = true
    lastVerifyCode = code
  }
}

class VerifyPINInteractorFake: VerifyPINInteractorSpy {
  var nextVerifyCodeResult: Result<Bool, Never>?
  override func verify(code: String, callback: @escaping Result<Bool, Never>.Callback) {
    super.verify(code: code, callback: callback)
    if let result = nextVerifyCodeResult {
      callback(result)
    }
  }
}

class VerifyPINPresenterSpy: VerifyPINPresenterProtocol {
  let viewModel = VerifyPINViewModel()
  var interactor: VerifyPINInteractorProtocol?
  var router: VerifyPINModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var pinEnteredCalled = false
  private(set) var lastPinEnteredCode: String?
  func pinEntered(_ code: String) {
    pinEnteredCalled = true
    lastPinEnteredCode = code
  }

  private(set) var forgotPINTappedCalled = false
  func forgotPINTapped() {
    forgotPINTappedCalled = true
  }
}
