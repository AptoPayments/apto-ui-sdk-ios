//
//  BiometricPermissionTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

@testable import AptoSDK
@testable import AptoUISDK

class BiometricPermissionModuleSpy: UIModuleSpy, BiometricPermissionModuleProtocol {
  private(set) var requestBiometricPermissionCalled = false
  func requestBiometricPermission(completion: @escaping (_ granted: Bool) -> Void) {
    requestBiometricPermissionCalled = true
  }
}

class BiometricPermissionModuleFake: BiometricPermissionModuleSpy {
  var nextRequestBiometricPermissionGrantedResult: Bool?
  override func requestBiometricPermission(completion: @escaping (_ granted: Bool) -> Void) {
    super.requestBiometricPermission(completion: completion)
    if let result = nextRequestBiometricPermissionGrantedResult {
      completion(result)
    }
  }
}

class BiometricPermissionInteractorSpy: BiometricPermissionInteractorProtocol {
  private(set) var setIsBiometricPermissionEnabledCalled = false
  private(set) var lastIsBiometricPermissionEnabled: Bool?
  func setBiometricPermissionEnabled(_ isEnabled: Bool) {
    setIsBiometricPermissionEnabledCalled = true
    lastIsBiometricPermissionEnabled = isEnabled
  }
}

class BiometricPermissionInteractorFake: BiometricPermissionInteractorSpy {
}

class BiometricPermissionPresenterSpy: BiometricPermissionPresenterProtocol {
  let viewModel = BiometricPermissionViewModel()
  var interactor: BiometricPermissionInteractorProtocol?
  var router: BiometricPermissionModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var requestPermissionTappedCalled = false
  func requestPermissionTapped() {
    requestPermissionTappedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }
}
