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
  var view: AccountSettingsViewProtocol!
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
}
