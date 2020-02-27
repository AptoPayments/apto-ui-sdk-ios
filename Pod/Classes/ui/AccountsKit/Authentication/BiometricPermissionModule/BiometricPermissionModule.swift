//
//  BiometricPermissionModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

import Foundation
import AptoSDK

class BiometricPermissionModule: UIModule, BiometricPermissionModuleProtocol {
  private var presenter: BiometricPermissionPresenterProtocol?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  func requestBiometricPermission(completion: @escaping (_ granted: Bool) -> Void) {
    let authManager = serviceLocator.systemServicesLocator.authenticationManager()
    authManager.authenticate(from: self, mode: .biometry, completion: completion)
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.biometricPermissionPresenter()
    let interactor = serviceLocator.interactorLocator.biometricPermissionInteractor()
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.biometricPermissionView(presenter: presenter)
  }
}
