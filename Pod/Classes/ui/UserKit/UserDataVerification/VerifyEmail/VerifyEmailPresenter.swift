//
//  VerifyEmailPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/10/2016.
//
//

import AptoSDK
import Bond

protocol VerifyEmailInteractorProtocol {
  func provideEmail()
  func resendPin()
  func submitPin(_ pin: String)
}


class VerifyEmailPresenter: PINVerificationPresenter, VerifyEmailDataReceiver {

  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: VerifyEmailInteractorProtocol!
  weak var router: VerifyEmailRouterProtocol!
  var view: PINVerificationView!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = PINVerificationViewModel()

  func viewLoaded() {
    viewModel.title.next("auth.verify_email.title".podLocalized())
    viewModel.subtitle.next("auth.verify_email.explanation".podLocalized())
    viewModel.resendButtonState.next(.enabled)
    interactor.provideEmail()
  }

  func submitTapped(_ pin: String) {
    view.showLoadingSpinner()
    interactor.submitPin(pin)
  }

  func resendTapped() {
    view.showLoadingSpinner()
    interactor.resendPin()
  }

  func closeTapped() {
    router.closeTappedInVerifyEmail()
  }

  func emailReceived(_ email: Email) {
    if let emailAddress = email.email.value {
      viewModel.datapointValue.next(emailAddress)
    }
  }

  func unknownEmail() {
    viewModel.datapointValue.next("")
  }

  func verificationReceived(_ verification: Verification) {
    view.hideLoadingSpinner()
  }

  func sendPinError(_ error: NSError) {
    view.show(error: error)
  }

  func sendPinSuccess() {
    view.hideLoadingSpinner()
  }

  func pinVerificationSucceeded(_ verification: Verification) {
    view.hideLoadingSpinner()
    router.nextTappedInVerifyEmailWith(verification: verification)
  }

  func pinVerificationFailed() {
    view.hideLoadingSpinner()
    view.showWrongPinError(error: BackendError(code: .emailVerificationFailed),
                           title: "auth.verify_email.error_wrong_code.title".podLocalized())
  }

}
