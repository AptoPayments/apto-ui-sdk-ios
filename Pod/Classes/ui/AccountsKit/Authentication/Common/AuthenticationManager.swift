//
//  AuthenticationManager.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

import Foundation
import AptoSDK

enum AuthenticationMode {
  case biometry
  case passcode
  case allAvailables
}

protocol AuthenticationManagerProtocol {
  var biometryType: BiometryType { get }
  var shouldRequestBiometricPermission: Bool { get }
  
  func save(code: String) -> Result<Void, NSError>
  func codeExists() -> Bool
  func isValid(code: String) -> Bool
  func shouldCreateCode() -> Bool
  func canChangeCode() -> Bool
  func shouldAuthenticateOnStartUp() -> Bool
  func authenticate(from: UIModuleProtocol, mode: AuthenticationMode, completion: @escaping (Bool) -> Void)
  func invalidateCurrentCode()
}

extension AuthenticationManagerProtocol {
  func authenticate(from: UIModuleProtocol, mode: AuthenticationMode = .allAvailables,
                    completion: @escaping (Bool) -> Void) {
    authenticate(from: from, mode: mode, completion: completion)
  }
}

private let AUTH_REQUEST_TIME_SECONDS = 60

class AuthenticationManager: AuthenticationManagerProtocol {
  private let fileManager: FileManagerProtocol
  private let dateProvider: DateProviderProtocol
  private let aptoPlatform: AptoPlatformProtocol
  private let authenticator: AuthenticatorProtocol
  private var lastAuthenticationDate: Date?
  private var lastAuthenticationMode: AuthenticationMode?

  var biometryType: BiometryType { authenticator.biometryType }
  private var isBiometricEnabledByUser: Bool { aptoPlatform.isBiometricEnabled() }
  var shouldRequestBiometricPermission: Bool {
    // if biometric is already enabled no need to ask for the permission
    guard isBiometricEnabledByUser == false else { return false }
    return (biometryType != .none && authenticator.isBiometryAvailable)
  }

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
      lastAuthenticationMode = .allAvailables
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
      lastAuthenticationMode = .allAvailables
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
    return shouldAuthenticate()
  }

  func authenticate(from: UIModuleProtocol, mode: AuthenticationMode, completion: @escaping (Bool) -> Void) {
    guard shouldAuthenticate(mode: mode) else {
      completion(true)
      return
    }
    // do not use biometry if not enabled by the user, unless "forced" by the caller
    let authMode = (isFeatureEnabled() && !isBiometricEnabledByUser && mode != .biometry) ? .passcode : mode
    authenticator.authenticate(from: from, mode: authMode) { [unowned self] accessGranted in
      if accessGranted {
        self.lastAuthenticationDate = self.dateProvider.currentDate()
        self.lastAuthenticationMode = mode
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

  private func shouldAuthenticate(mode: AuthenticationMode = .allAvailables) -> Bool {
    guard let lastDate = lastAuthenticationDate, mode == lastAuthenticationMode else { return true }
    let currentDate = dateProvider.currentDate()
    let components = Calendar.current.dateComponents([.second], from: lastDate, to: currentDate)
    return components.second! > AUTH_REQUEST_TIME_SECONDS // swiftlint:disable:this force_unwrapping
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
