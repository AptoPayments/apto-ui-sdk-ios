//
//  Authenticator.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 12/03/2018.
//

protocol AuthenticatorProtocol {
  var biometryType: BiometryType { get }
  var isBiometryAvailable: Bool { get }

  func authenticate(from: UIModuleProtocol, mode: AuthenticationMode, completion: @escaping (Bool) -> Void)
    func authenticateOnStartup(from: UIModuleProtocol, completion: @escaping (Bool) -> Void)
    func requestBiometricPermission(from: UIModuleProtocol, completion: @escaping (Bool) -> Void)
}

class Authenticator: AuthenticatorProtocol {
  private let serviceLocator: ServiceLocatorProtocol
  private var verifyPasscodeModule: VerifyPasscodeModuleProtocol?
  private lazy var localAuthenticationHandler = LocalAuthenticationHandler()

  lazy var biometryType: BiometryType = localAuthenticationHandler.biometryType
  var isBiometryAvailable: Bool { localAuthenticationHandler.available() }

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  private func authenticateWithBiometric(from: UIModuleProtocol, fallbackToPasscode: Bool,
                                         completion: @escaping (Bool) -> Void) {
    if localAuthenticationHandler.available() {
      localAuthenticationHandler.authenticate { [unowned self] result in
        DispatchQueue.main.async {
          switch result {
          case .failure:
            guard fallbackToPasscode, self.serviceLocator.platform.isAuthTypePinOrBiometricsEnabled() else {
              completion(false)
              return
            }
            self.verifyPasscode(from, completion)
          case .success(let accessGranted):
            completion(accessGranted)
          }
        }
      }
    }
    else if fallbackToPasscode {
      verifyPasscode(from, completion)
    }
    else {
      completion(true)
    }
  }

  func authenticate(from: UIModuleProtocol, mode: AuthenticationMode, completion: @escaping (Bool) -> Void) {
    switch mode {
    case .passcode:
      verifyPasscode(from, completion)
    case .biometry:
      authenticateWithBiometric(from: from, fallbackToPasscode: false, completion: completion)
    case .allAvailables:
      authenticateWithBiometric(from: from, fallbackToPasscode: true, completion: completion)
    case .none:
        DispatchQueue.main.async { completion(true) }
    }
  }

    func authenticateOnStartup(from: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
        showPasscodeModule(from, completion)
    }

    func requestBiometricPermission(from: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
        if localAuthenticationHandler.available() {
            localAuthenticationHandler.authenticate { result in
                DispatchQueue.main.async {
                    if let accessGranted = try? result.get() {
                        completion(accessGranted)
                    } else {
                        completion(false)
                    }
                }
            }
        } else {
            completion(true)
        }
    }
    
  private func verifyPasscode(_ from: UIModuleProtocol, _ completion: @escaping (Bool) -> Void) {
    guard serviceLocator.platform.isAuthTypePinOrBiometricsEnabled() else {
      completion(true)
      return
    }
    showPasscodeModule(from, completion)
  }

    private func showPasscodeModule(_ from: UIModuleProtocol, _ completion: @escaping (Bool) -> Void) {
        let module = serviceLocator.moduleLocator.verifyPasscodeModule()
        self.verifyPasscodeModule = module
        module.onFinish = { _ in
          from.dismissModule {
            self.verifyPasscodeModule = nil
            DispatchQueue.main.async { completion(true) }
          }
        }
        // swiftlint:disable:next force_cast
        from.present(module: module) { _ in }
    }
}
