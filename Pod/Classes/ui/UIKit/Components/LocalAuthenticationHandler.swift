//
//  LocalAuthenticationHandler.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/03/2018.
//

import AptoSDK
import LocalAuthentication

class LocalAuthenticationHandler {
  private let localAuthenticationContext = LAContext()

  var biometryType: BiometryType {
    // Even when this value is only used in the else branch we have to make the call in here because
    // biometryType is only set after canEvaluatePolicy(_, error:) is called.
    // https://developer.apple.com/documentation/localauthentication/lacontext/2867583-biometrytype
    let isBiometricSupported = isBiometricSupportedByDevice()
    if #available(iOS 11, *) {
      switch localAuthenticationContext.biometryType {
      case .faceID:
        return .faceID
      case .touchID:
        return .touchID
      case .none:
        return .none
      @unknown default:
        // How should we handle this scenario?
        return .none
      }
    }
    else {
      return isBiometricSupported ? .touchID : .none
    }
  }

  private func isBiometricSupportedByDevice() -> Bool {
    var authError: NSError?
    let canEvaluatePolicy = localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                                         error: &authError)
    // if the policy can be evaluated biometrics is supported
    guard canEvaluatePolicy == false else { return true }

    if let error = authError {
      if #available(iOS 11, macOS 10.13, *) {
        // biometryNotEnrolled is returned when biometrics is not available in the device
        return error.code != LAError.biometryNotEnrolled.rawValue
      }
      else {
        // iOS<11 returns touchIDNotEnrolled if the user opt-out using touch id or touchIDNotAvailable if the device
        // do not support biometrics
        return (error.code != LAError.touchIDNotEnrolled.rawValue && error.code != LAError.touchIDNotAvailable.rawValue)
      }
    }
    return true
  }

  func available() -> Bool {
    return localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }

  func authenticate(completion: @escaping Result<Bool, NSError>.Callback) {
    var authError: NSError?
    let reasonString = "Show the card info"
    if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
      localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                localizedReason: reasonString) { success, error in
        if success {
          completion(.success(true))
        }
        else {
          if let error = error {
            completion(.failure(error as NSError))
          }
          else {
            completion(.success(false))
          }
        }
      }
    }
    else {
      guard let error = authError else {
        completion(.success(false))
        return
      }
      completion(.failure(ServiceError(code: .internalIncosistencyError,
                                       reason: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))))
    }
  }

  func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
    var message = ""
    if #available(iOS 11.0, macOS 10.13, *) {
      switch errorCode {
      case LAError.biometryNotAvailable.rawValue:
        message = "Authentication could not start because the device does not support biometric authentication."
      case LAError.biometryLockout.rawValue:
        // swiftlint:disable:next line_length
        message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
      case LAError.biometryNotEnrolled.rawValue:
        message = "Authentication could not start because the user has not enrolled in biometric authentication."
      default:
        message = "Did not find error code on LAError object"
      }
    } else {
      switch errorCode {
      case LAError.touchIDLockout.rawValue:
        message = "Too many failed attempts."
      case LAError.touchIDNotAvailable.rawValue:
        message = "TouchID is not available on the device"
      case LAError.touchIDNotEnrolled.rawValue:
        message = "TouchID is not enrolled on the device"
      default:
        message = "Did not find error code on LAError object"
      }
    }
    return message
  }

  func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
    var message = ""
    switch errorCode {
    case LAError.authenticationFailed.rawValue:
      message = "The user failed to provide valid credentials"
    case LAError.appCancel.rawValue:
      message = "Authentication was cancelled by application"
    case LAError.invalidContext.rawValue:
      message = "The context is invalid"
    case LAError.notInteractive.rawValue:
      message = "Not interactive"
    case LAError.passcodeNotSet.rawValue:
      message = "Passcode is not set on the device"
    case LAError.systemCancel.rawValue:
      message = "Authentication was cancelled by the system"
    case LAError.userCancel.rawValue:
      message = "The user did cancel"
    case LAError.userFallback.rawValue:
      message = "The user chose to use the fallback"
    default:
      message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
    }
    return message
  }

}
