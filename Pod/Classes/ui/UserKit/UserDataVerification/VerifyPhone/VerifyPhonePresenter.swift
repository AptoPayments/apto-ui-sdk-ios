//
//  VerifyPhonePresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import AptoSDK
import Bond

protocol VerifyPhoneRouterProtocol: class {
  func closeTappedInVerifyPhone()
  func phoneVerificationPassed(verification: Verification)
}

protocol VerifyPhoneInteractorProtocol: class {
  func providePhoneNumber()
  func resendPin()
  func submitPin(_ pin: String)
}

protocol VerifyPhonePresenterProtocol: PINVerificationPresenter, VerifyPhoneDataReceiver {
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: VerifyPhoneInteractorProtocol! { get set }
  var router: VerifyPhoneRouterProtocol! { get set }
  var view: PINVerificationView! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: PINVerificationViewModel { get }
}

class VerifyPhonePresenter: VerifyPhonePresenterProtocol {

  struct Constants {
    static let waitSeconds = 45
  }

  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: VerifyPhoneInteractorProtocol!
  weak var router: VerifyPhoneRouterProtocol!
  var view: PINVerificationView!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = PINVerificationViewModel()
    var countDown: CountDown!
  var userTriggeredResendPin = false

  func viewLoaded() {
    viewModel.title.next("auth.verify_phone.title".podLocalized())
    viewModel.subtitle.next("auth.verify_phone.explanation".podLocalized())
    viewModel.pinEntryState.next(.enabled)
    interactor.providePhoneNumber()
  }

  func submitTapped(_ pin: String) {
    view.showLoadingSpinner()
    interactor.submitPin(pin)
  }

  func resendTapped() {
    view.showLoadingSpinner()
    interactor.resendPin()
    userTriggeredResendPin = true
  }

  func closeTapped() {
    router.closeTappedInVerifyPhone()
  }

  func phoneNumberReceived(_ phone: PhoneNumber) {
    guard let nationalNumber = phone.phoneNumber.value else {
      viewModel.datapointValue.next("??")
      return
    }
    let phoneNumber = PhoneHelper.sharedHelper().formatPhoneWith(countryCode: phone.countryCode.value,
                                                                 nationalNumber: nationalNumber,
                                                                 numberFormat: .nationalWithPrefix)
    viewModel.datapointValue.next(phoneNumber)
  }

  func unknownPhoneNumber() {
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
    startResendPinCountDown()
    viewModel.pinEntryState.next(.enabled)
    if (userTriggeredResendPin) { view.showPinResent() }
  }

  func pinVerificationSucceeded(_ verification: Verification) {
    view.hideLoadingSpinner()
    countDown.stop()
    router.phoneVerificationPassed(verification: verification)
  }

  func pinVerificationWrongPin() {
    view.hideLoadingSpinner()
    view.showWrongPinError(error: BackendError(code: .phoneVerificationFailed),
                           title: "auth.verify_phone.error_wrong_code.title".podLocalized())
  }

  func pinVerificationExpired() {
    view.hideLoadingSpinner()
    viewModel.pinEntryState.next(.expired)
  }

  func pinVerificationError(_ error: NSError) {
    view.show(error: error)
  }

  private func startResendPinCountDown() {
    viewModel.footerTitle.next("auth.verify_phone.footer".podLocalized())
    viewModel.resendButtonState.next(.waiting(pendingSeconds: Constants.waitSeconds))
    countDown = CountDown()
    countDown.start(
      seconds: Constants.waitSeconds + 1,
      fireBlock: { [weak self] pendingSeconds in
        self?.viewModel.resendButtonState.next(.waiting(pendingSeconds: pendingSeconds))
      },
      endBlock: { [weak self] in
        self?.viewModel.resendButtonState.next(.enabled)
        self?.countDown.stop()
    })
  }
}
