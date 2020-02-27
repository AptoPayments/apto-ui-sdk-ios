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
  func showMonthlyStatements()
  func showChangePasscode()
}

typealias AccountSettingsViewProtocol = ShiftViewController

protocol AccountSettingsInteractorProtocol {
  func isBiometricEnabled() -> Bool
  func setIsBiometricEnabled(_ isEnabled: Bool)
  func logoutCurrentUser()
}

class AccountSettingsViewModel {
  let showNotificationPreferences: Observable<Bool> = Observable(false)
  let showMonthlyStatements: Observable<Bool> = Observable(false)
  let showChangePasscode: Observable<Bool> = Observable(false)
  let biometryType: Observable<BiometryType> = Observable(.none)
  let isBiometricEnabled: Observable<Bool> = Observable(false)
}

struct AccountSettingsPresenterConfig {
  let showNotificationPreferences: Bool
  let showMonthlyStatements: Bool
  let showChangePIN: Bool
  let biometryType: BiometryType
}

protocol AccountSettingsPresenterProtocol: class {
  var viewModel: AccountSettingsViewModel { get }
  var interactor: AccountSettingsInteractorProtocol! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
  var router: AccountSettingsRouterProtocol! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func logoutTapped()
  func contactTapped()
  func notificationsTapped()
  func monthlyStatementsTapped()
  func changePasscodeTapped()
  func changeShowBiometricTapped(_ isEnabled: Bool)
}
