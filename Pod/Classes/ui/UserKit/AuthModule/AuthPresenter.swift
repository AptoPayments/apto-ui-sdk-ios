//
//  AuthPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

import UIKit
import AptoSDK
import ReactiveKit

class AuthPresenter: AuthPresenterProtocol {
  private let disposeBag = DisposeBag()
  private let config: AuthModuleConfig
  private let uiConfig: UIConfig

  // swiftlint:disable implicitly_unwrapped_optional
  var viewController: AuthViewProtocol!
  var interactor: AuthInteractorProtocol!
  weak var router: AuthRouterProtocol!
  private var primaryCredentialStep: DataCollectorStepProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: AuthModuleConfig, uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    self.config = config
  }

  // MARK: AuthEventHandler protocol

  func viewLoaded() {
    self.interactor.provideAuthData()
  }

  func set(_ userData: DataPointList,
           primaryCredentialType: DataPointType,
           secondaryCredentialType: DataPointType) {
    switch primaryCredentialType {
    case .phoneNumber:
      primaryCredentialStep = AuthPhoneStep(userData: userData,
                                            allowedCountries: config.allowedCountries,
                                            uiConfig: uiConfig)
      analyticsManager?.track(event: Event.authInputPhone)
    case .email:
      primaryCredentialStep = AuthEmailStep(userData: userData, uiConfig: uiConfig)
      analyticsManager?.track(event: Event.authInputEmail)
    default:
      // TODO: Support BirthDate as a primary credential
      break
    }
    viewController.show(fields: primaryCredentialStep.rows)
    setViewTitles(primaryCredentialType, viewController)
    viewController.showCancelButton()
    viewController.showNextButton()
    self.viewController.update(progress: 10)
    primaryCredentialStep.valid.removeDuplicates().observeNext { [weak self] validStep in
      if validStep { self?.viewController.activateNextButton() }
      else { self?.viewController.deactivateNextButton() }
    }.dispose(in: disposeBag)
  }

  func setViewTitles(_ type: DataPointType, _ viewController: AuthViewProtocol) {
    switch type {
    case .phoneNumber:
      viewController.setTitle("auth.input_phone.title".podLocalized())
      viewController.setExplainationTitle("auth.input_phone.explanation".podLocalized())
      viewController.setButtonTitle("auth.input_phone.call_to_action.title".podLocalized())
    case .email:
      viewController.setTitle("auth.input_email.title".podLocalized())
      viewController.setExplainationTitle("auth.input_email.explanation".podLocalized())
      viewController.setButtonTitle("auth.input_email.call_to_action.title".podLocalized())
    default:
      viewController.setTitle("")
      viewController.setExplainationTitle("")
      viewController.setButtonTitle("")
    }
  }

  func nextTapped() {
    interactor.nextTapped()
  }

  func closeTapped() {
    router.close()
  }

  func showLoadingView() {
    viewController.showLoadingView()
  }

  func hideLoadingView() {
    viewController.hideLoadingView()
  }

  // MARK: - AuthDataReceiver protocol

  func showPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>) {
    analyticsManager?.track(event: Event.authVerifyPhone)
    router.presentPhoneVerification(verificationType: verificationType) { [weak self] result in
      switch result {
      case .failure:
        self?.interactor.phoneVerificationFailed()
      case .success(let verification):
        self?.interactor.phoneVerificationSucceeded(verification)
      }
    }
  }

  func showEmailVerification(verificationType: VerificationParams<Email, Verification>) {
    analyticsManager?.track(event: Event.authVerifyEmail)
    router.presentEmailVerification(verificationType: verificationType) { [weak self] result in
      switch result {
      case .failure:
        self?.interactor.emailVerificationFailed()
      case .success(let verification):
        self?.interactor.emailVerificationSucceeded(verification)
      }
    }
  }

  func showBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>) {
    analyticsManager?.track(event: Event.authVerifyBirthdate)
    router.presentBirthdateVerification(verificationType: verificationType) { [weak self] result in
      switch result {
      case .failure:
        self?.interactor.birthdateVerificationFailed()
      case .success(let verification):
        self?.interactor.birthdateVerificationSucceeded(verification)
      }
    }
  }

  func show(error: NSError) {
    viewController.show(error: error)
  }

  func returnExistingUser(_ user: AptoUser) {
    router.returnExistingUser(user)
  }

}
