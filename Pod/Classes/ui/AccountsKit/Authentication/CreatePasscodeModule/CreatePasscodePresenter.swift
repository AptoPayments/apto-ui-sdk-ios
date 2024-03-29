//
//  CreatePasscodePresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
import Foundation

class CreatePasscodePresenter: CreatePasscodePresenterProtocol {
    var router: CreatePasscodeModuleProtocol?
    var interactor: CreatePasscodeInteractorProtocol?
    var viewModel = CreatePasscodeViewModel()
    var analyticsManager: AnalyticsServiceProtocol?

    func viewLoaded() {
        analyticsManager?.track(event: .createPasscodeStart)
    }

    func closeTapped() {
        router?.close()
    }

    func pinEntered(_ code: String) {
        interactor?.save(code: code) { [weak self] result in
            switch result {
            case let .failure(error):
                self?.viewModel.error.send(error)
            case .success:
                self?.router?.finish(result: nil)
            }
        }
    }
}
