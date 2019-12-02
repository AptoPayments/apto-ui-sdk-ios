//
//  VerifyPINContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import AptoSDK
import Bond

protocol VerifyPINModuleProtocol: UIModuleProtocol {
  func showForgotPIN()
}

protocol VerifyPINInteractorProtocol {
  func verify(code: String, callback: @escaping Result<Bool, Never>.Callback)
}

class VerifyPINViewModel {
  let logoURL: Observable<String?> = Observable(nil)
  let error: Observable<NSError?> = Observable(nil)
}

struct VerifyPINPresenterConfig {
  let logoURL: String?
}

protocol VerifyPINPresenterProtocol: class {
  var router: VerifyPINModuleProtocol? { get set }
  var interactor: VerifyPINInteractorProtocol? { get set }
  var viewModel: VerifyPINViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func pinEntered(_ code: String)
  func forgotPINTapped()
}

class WrongPINError: NSError {
  init() {
    let errorMessage = "biometric.verify_pin.error.wrong_pin".podLocalized()
    let userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorMessage]
    super.init(domain: "com.aptopayments.sdk.error.save_file", code: 1002, userInfo: userInfo)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
