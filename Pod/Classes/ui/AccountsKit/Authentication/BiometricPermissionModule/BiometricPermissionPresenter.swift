//
//  BiometricPermissionPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

import AptoSDK
import Bond

class BiometricPermissionPresenter: BiometricPermissionPresenterProtocol {
    var router: BiometricPermissionModuleProtocol?
    var interactor: BiometricPermissionInteractorProtocol?
    var viewModel = BiometricPermissionViewModel()
    var analyticsManager: AnalyticsServiceProtocol?

    func viewLoaded() {
        analyticsManager?.track(event: .biometricPermissionStart)
        viewModel.biometryType.send(.faceID)
    }

    func requestPermissionTapped() {
        router?.requestBiometricPermission { [weak self] granted in
            guard let self = self else { return }
            self.interactor?.setBiometricPermissionEnabled(granted)
            if granted {
                self.router?.finish(result: nil)
            } else {
                self.router?.close()
            }
        }
    }

    func closeTapped() {
        interactor?.setBiometricPermissionEnabled(false)
        router?.close()
    }
}
