//
//  VerifyPasscodePresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import AptoSDK
import Bond

class VerifyPasscodePresenter: VerifyPasscodePresenterProtocol {
  private let config: VerifyPasscodePresenterConfig
  var router: VerifyPasscodeModuleProtocol?
  var interactor: VerifyPasscodeInteractorProtocol?
  var viewModel = VerifyPasscodeViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: VerifyPasscodePresenterConfig) {
    self.config = config
  }

  func viewLoaded() {
    viewModel.logoURL.send(config.logoURL)
    analyticsManager?.track(event: .verifyPasscodeStart)
  }

  func pinEntered(_ code: String) {
    interactor?.verify(code: code) { [weak self] result in
      let isValid = result.value! // swiftlint:disable:this force_unwrapping
      if isValid {
        self?.router?.finish(result: nil)
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
