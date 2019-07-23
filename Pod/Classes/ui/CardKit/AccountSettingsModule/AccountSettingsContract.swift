//
//  AccountSettingsContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import Bond
import AptoSDK

protocol AccountSettingsRouterProtocol: class {
  func closeFromAccountSettings()
  func contactTappedInAccountSettings()
  func notificationsTappedInAccountSettings()
}

typealias AccountSettingsViewProtocol = ShiftViewController

protocol AccountSettingsInteractorProtocol {
  func logoutCurrentUser()
}

class AccountSettingsViewModel {
  let showNotificationPreferences: Observable<Bool> = Observable(false)
}

struct AccountSettingsPresenterConfig {
  let showNotificationPreferences: Bool
}

protocol AccountSettingsPresenterProtocol: class {
  var viewModel: AccountSettingsViewModel { get }
  var view: AccountSettingsViewProtocol! { get set }
  var interactor: AccountSettingsInteractorProtocol! { get set }
  var router: AccountSettingsRouterProtocol! { get set }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func logoutTapped()
  func contactTapped()
  func notificationsTapped()
}
