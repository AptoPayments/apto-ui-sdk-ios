//
//  VerifyPINPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import AptoSDK
import Bond

class VerifyPINPresenter: VerifyPINPresenterProtocol {
  private let config: VerifyPINPresenterConfig
  var router: VerifyPINModuleProtocol?
  var interactor: VerifyPINInteractorProtocol?
  var viewModel = VerifyPINViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: VerifyPINPresenterConfig) {
    self.config = config
  }

  func viewLoaded() {
    viewModel.logoURL.send(config.logoURL)
    analyticsManager?.track(event: .verifyPINStart)
  }

  func pinEntered(_ code: String) {
    interactor?.verify(code: code) { [weak self] result in
      let isValid = result.value! // swiftlint:disable:this force_unwrapping
      if isValid {
        self?.router?.finish()
      }
      else {
        self?.viewModel.error.send(WrongPINError())
      }
    }
  }

  func forgotPINTapped() {
    router?.showForgotPIN()
  }
}
