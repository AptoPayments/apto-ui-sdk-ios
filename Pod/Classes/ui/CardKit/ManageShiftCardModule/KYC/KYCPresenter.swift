//
//  KYCPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 09/04/2017.
//
//

import Foundation
import AptoSDK
import Bond

class KYCPresenter: KYCPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: KYCViewProtocol!
  var interactor: KYCInteractorProtocol!
  weak var router: KYCRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: KYCViewModel
  var analyticsManager: AnalyticsServiceProtocol?

  init() {
    self.viewModel = KYCViewModel()
  }

  func viewLoaded() {
    interactor.provideKYCInfo { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
      case .success(let kyc):
        self?.viewModel.kycState.next(kyc)
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
      case .failure(let error):
        self.view.show(error: error)
      case .success(let kyc):
        self.viewModel.kycState.next(kyc)
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
