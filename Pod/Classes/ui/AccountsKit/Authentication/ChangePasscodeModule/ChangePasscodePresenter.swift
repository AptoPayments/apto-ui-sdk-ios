//
//  ChangePasscodePresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 13/02/2020.
//

import AptoSDK
import Bond

class ChangePasscodePresenter: ChangePasscodePresenterProtocol {
  var router: ChangePasscodeModuleProtocol?
  var interactor: ChangePasscodeInteractorProtocol?
  var viewModel = ChangePasscodeViewModel()
  var analyticsManager: AnalyticsServiceProtocol?
  var newPasscode: String?

  func viewLoaded() {
    analyticsManager?.track(event: .changePasscodeStart)
  }

  func closeTapped() {
    router?.close()
  }

  func passcodeEntered(_ passcode: String) {
    let currentStep = viewModel.step.value
    switch currentStep {
    case .verifyPasscode:
      verify(passcode)
    case .setPasscode:
      set(passcode)
    case .confirmPasscode:
      confirm(passcode)
    }
  }

  func forgotPasscodeTapped() {
    router?.showForgotPasscode()
  }

  private func verify(_ passcode: String) {
    interactor?.verify(code: passcode) { [weak self] result in
      let isValid = result.value ?? false
      if isValid {
        self?.viewModel.step.send(.setPasscode)
      }
      else {
        self?.viewModel.error.send(WrongPINError())
      }
    }
  }

  private func set(_ passcode: String) {
    newPasscode = passcode
    viewModel.step.send(.confirmPasscode)
  }

  private func confirm(_ passcode: String) {
    guard passcode == newPasscode else {
      viewModel.step.send(.setPasscode)
      viewModel.error.send(PasscodeDoNotMatchError())
      return
    }
    interactor?.save(code: passcode) { [weak self] result in
      switch result {
      case .failure(let error):
        self?.viewModel.error.send(error)
        self?.viewModel.step.send(.setPasscode)
      case .success:
        self?.router?.finish(result: nil)
      }
    }
  }
}
