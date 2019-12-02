//
//  AuthenticationManager.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

import Foundation
import AptoSDK

protocol AuthenticationManagerProtocol {
  func save(code: String) -> Result<Void, NSError>
  func codeExists() -> Bool
  func isValid(code: String) -> Bool
  func shouldCreateCode() -> Bool
  func canChangeCode() -> Bool
  func shouldAuthenticateOnStartUp() -> Bool
  func authenticate(from: UIModuleProtocol, completion: @escaping (Bool) -> Void)
  func invalidateCurrentCode()
}

private let AUTH_REQUEST_TIME_SECONDS = 60

class AuthenticationManager: AuthenticationManagerProtocol {
  private let fileManager: FileManagerProtocol
  private let dateProvider: DateProviderProtocol
  private let aptoPlatform: AptoPlatformProtocol
  private let authenticator: AuthenticatorProtocol
  private var lastAuthenticationDate: Date?

  init(fileManager: FileManagerProtocol, dateProvider: DateProviderProtocol, aptoPlatform: AptoPlatformProtocol,
       authenticator: AuthenticatorProtocol) {
    self.fileManager = fileManager
    self.dateProvider = dateProvider
    self.aptoPlatform = aptoPlatform
    self.authenticator = authenticator
  }

  func save(code: String) -> Result<Void, NSError> {
    let data = code.data(using: .utf8)! // swiftlint:disable:this force_unwrapping
    do {
      try fileManager.save(data: data)
      lastAuthenticationDate = dateProvider.currentDate()
      _currentPIN = code
      return .success(Void())
    }
    catch {
      return .failure(PINSaveError())
    }
  }

  func codeExists() -> Bool {
    return currentPIN() != nil
  }

  func isValid(code: String) -> Bool {
    if (currentPIN() == code) {
      lastAuthenticationDate = dateProvider.currentDate()
      return true
    }
    return false
  }

  func shouldCreateCode() -> Bool {
    return !codeExists() && isFeatureEnabled()
  }

  func canChangeCode() -> Bool {
    return isFeatureEnabled() && codeExists()
  }

  func shouldAuthenticateOnStartUp() -> Bool {
    guard aptoPlatform.isFeatureEnabled(.authenticateOnStartUp), codeExists() else { return false }
    guard let lastDate = lastAuthenticationDate else { return true }
    let currentDate = dateProvider.currentDate()
    let components = Calendar.current.dateComponents([.second], from: lastDate, to: currentDate)
    return components.second! > AUTH_REQUEST_TIME_SECONDS // swiftlint:disable:this force_unwrapping
  }

  func authenticate(from: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
    authenticator.authenticate(from: from) { [unowned self] accessGranted in
      if accessGranted {
        self.lastAuthenticationDate = self.dateProvider.currentDate()
      }
      completion(accessGranted)
    }
  }

  func invalidateCurrentCode() {
    _currentPIN = nil
    lastAuthenticationDate = nil
    try? fileManager.delete()
  }

  // MARK: - Helpers
  private var _currentPIN: String?
  private func currentPIN() -> String? {
    if _currentPIN == nil {
      guard let data = try? fileManager.read() else { return nil }
      _currentPIN = String(data: data, encoding: .utf8)
    }
    return _currentPIN
  }

  private func isFeatureEnabled() -> Bool {
    return aptoPlatform.isFeatureEnabled(.authenticateOnStartUp) ||
      aptoPlatform.isFeatureEnabled(.authenticateWithPINOnPCI)
  }
}

class PINSaveError: NSError {
  init() {
    let errorMessage = "biometric.auth_manager.error.save_pin".podLocalized()
    let userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorMessage]
    super.init(domain: "com.aptopayments.sdk.error.save_file", code: 1001, userInfo: userInfo)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
