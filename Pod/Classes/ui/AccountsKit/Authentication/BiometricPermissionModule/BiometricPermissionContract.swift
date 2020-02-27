//
//  BiometricPermissionContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

import AptoSDK
import Bond

protocol BiometricPermissionModuleProtocol: UIModuleProtocol {
  func requestBiometricPermission(completion: @escaping (_ granted: Bool) -> Void)
}

protocol BiometricPermissionInteractorProtocol {
  func setBiometricPermissionEnabled(_ isEnabled: Bool)
}

class BiometricPermissionViewModel {
  let biometryType: Observable<BiometryType> = Observable(.faceID)
}

protocol BiometricPermissionPresenterProtocol: class {
  var router: BiometricPermissionModuleProtocol? { get set }
  var interactor: BiometricPermissionInteractorProtocol? { get set }
  var viewModel: BiometricPermissionViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func requestPermissionTapped()
  func closeTapped()
}
