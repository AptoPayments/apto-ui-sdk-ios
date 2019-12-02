//
//  Authenticator.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 12/03/2018.
//

protocol AuthenticatorProtocol {
  func authenticate(from: UIModuleProtocol, completion: @escaping (Bool) -> Void)
}

class Authenticator: AuthenticatorProtocol {
  private let serviceLocator: ServiceLocatorProtocol
  private var verifyPINModule: VerifyPINModuleProtocol?

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func authenticate(from: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
    let localAuthenticationHandler = LocalAuthenticationHandler()
    if localAuthenticationHandler.available() {
      localAuthenticationHandler.authenticate { [unowned self] result in
        DispatchQueue.main.async {
          switch result {
          case .failure:
            guard self.serviceLocator.platform.isFeatureEnabled(.authenticateWithPINOnPCI) else {
              completion(false)
              return
            }
            self.verifyPIN(from, completion)
          case .success(let accessGranted):
            completion(accessGranted)
          }
        }
      }
    }
    else {
      verifyPIN(from, completion)
    }
  }

  private func verifyPIN(_ from: UIModuleProtocol, _ completion: @escaping (Bool) -> Void) {
    guard serviceLocator.platform.isFeatureEnabled(.authenticateWithPINOnPCI) else {
      completion(true)
      return
    }
    let module = serviceLocator.moduleLocator.verifyPINModule()
    self.verifyPINModule = module
    module.onFinish = { _ in
      from.dismissModule {
        self.verifyPINModule = nil
        DispatchQueue.main.async { completion(true) }
      }
    }
    // swiftlint:disable:next force_cast
    from.present(module: module) { _ in }
  }
}
