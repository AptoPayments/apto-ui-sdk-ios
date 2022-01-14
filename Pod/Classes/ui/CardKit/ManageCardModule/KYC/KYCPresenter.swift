//
//  KYCPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 09/04/2017.
//
//

import AptoSDK
import Bond
import Foundation

class KYCPresenter: KYCPresenterProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var view: KYCViewProtocol!
    var interactor: KYCInteractorProtocol!
    weak var router: KYCRouterProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    var viewModel: KYCViewModel
    var analyticsManager: AnalyticsServiceProtocol?

    init() {
        viewModel = KYCViewModel()
    }

    func viewLoaded() {
        interactor.provideKYCInfo { [weak self] result in
            switch result {
            case let .failure(error):
                self?.view.show(error: error)
            case let .success(kyc):
                self?.viewModel.kycState.send(kyc)
            }
        }
        analyticsManager?.track(event: Event.manageCardKycStatus)
    }

    func closeTapped() {
        router.closeFromKYC()
    }

    func refreshTapped() {
        view.showLoadingSpinner()
        interactor.provideKYCInfo { [weak self] result in
            guard let self = self else { return }
            self.view.hideLoadingSpinner()
            switch result {
            case let .failure(error):
                self.view.show(error: error)
            case let .success(kyc):
                self.viewModel.kycState.send(kyc)
                if let kyc = kyc {
                    switch kyc {
                    case .passed:
                        self.router.kycPassed()
                    default:
                        break
                    }
                }
            }
        }
    }

    func show(url: URL) {
        router.show(url: url)
    }
}
