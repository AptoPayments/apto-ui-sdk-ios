//
// SetPinPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/06/2019.
//

import Foundation
import AptoSDK
import Bond

class SetPinPresenter: SetPinPresenterProtocol {
  let viewModel = SetPinViewModel()
  var router: SetPinModuleProtocol?
  var interactor: SetPinInteractorProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  func viewLoaded() {
    analyticsManager?.track(event: .setPin)
  }

  func pinEntered(_ pin: String) {
    analyticsManager?.track(event: .setPinConfirmed)
    viewModel.showLoading.send(true)
    interactor?.changePin(pin) { [weak self] result in
      self?.viewModel.showLoading.send(false)
      switch result {
      case .failure(let error):
        self?.viewModel.error.send(error)
      case .success:
        self?.router?.pinChanged()
      }
    }
  }

  func closeTapped() {
    router?.close()
  }
}
