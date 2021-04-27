//
//  AccountSettingsPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import Foundation
import AptoSDK

class AccountSettingsPresenter: AccountSettingsPresenterProtocol {
  let viewModel = AccountSettingsViewModel()
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: AccountSettingsInteractorProtocol!
  weak var router: AccountSettingsRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  private let config: AccountSettingsPresenterConfig
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: AccountSettingsPresenterConfig) {
    self.config = config
  }

  func viewLoaded() {
    viewModel.showNotificationPreferences.send(config.showNotificationPreferences)
    viewModel.showChangePasscode.send(config.showChangePIN)
    viewModel.isBiometricEnabled.send(interactor.isBiometricEnabled())
    viewModel.biometryType.send(config.biometryType)
    analyticsManager?.track(event: Event.accountSettings)
  }

  func closeTapped() {
    router.closeFromAccountSettings()
  }

  func logoutTapped() {
    interactor.logoutCurrentUser()
  }

  func contactTapped() {
    router.contactTappedInAccountSettings()
  }

  func notificationsTapped() {
    router.notificationsTappedInAccountSettings()
  }

  func changePasscodeTapped() {
    router.showChangePasscode()
  }

  func changeShowBiometricTapped(_ isEnabled: Bool) {
    interactor.setIsBiometricEnabled(isEnabled)
    viewModel.isBiometricEnabled.send(isEnabled)
  }
}
