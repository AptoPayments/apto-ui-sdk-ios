//
//  ViewLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//

import UIKit
import AptoSDK

final class ViewLocator: ViewLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol
 
  private var uiConfig: UIConfig {
    return serviceLocator.uiConfig ?? .default
  }

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fullScreenDisclaimerView(uiConfig: UIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController {
     return FullScreenDisclaimerViewControllerTheme2(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func countrySelectorView(presenter: CountrySelectorPresenterProtocol) -> ShiftViewController {
    return CountrySelectorViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
  }

  func authView(uiConfig: UIConfig, mode: ShiftCardModuleMode, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    return AuthViewControllerTheme2(uiConfiguration: uiConfig, mode: mode, eventHandler: eventHandler)
  }

  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol {
    return PINVerificationViewControllerTheme2(uiConfig: uiConfig, presenter: presenter)
  }

  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol {
    return VerifyBirthDateViewControllerTheme2(uiConfig: uiConfig, presenter: presenter)
  }

  func externalOAuthView(uiConfiguration: UIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    return ExternalOAuthViewControllerTheme2(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
  }

  // MARK: - Biometrics
  func createPasscodeView(presenter: CreatePasscodePresenterProtocol) -> ShiftViewController {
    return CreatePasscodeViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func verifyPasscodeView(presenter: VerifyPasscodePresenterProtocol) -> ShiftViewController {
    return VerifyPasscodeViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func changePasscodeView(presenter: ChangePasscodePresenterProtocol) -> ShiftViewController {
    return ChangePasscodeViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func biometricPermissionView(presenter: BiometricPermissionPresenterProtocol) -> ShiftViewController {
    return BiometricPermissionViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func issueCardView(uiConfig: UIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
    return IssueCardViewControllerTheme2(uiConfiguration: uiConfig, presenter: eventHandler)
  }

  func waitListView(presenter: WaitListPresenterProtocol) -> ShiftViewController {
    return WaitListViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func serverMaintenanceErrorView(uiConfig: UIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController {
    return ServerMaintenanceErrorViewControllerTheme2(uiConfig: uiConfig, eventHandler: eventHandler)
  }

  func accountsSettingsView(uiConfig: UIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol {
    return AccountSettingsViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  func contentPresenterView(uiConfig: UIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController {
     return ContentPresenterViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func dataConfirmationView(uiConfig: UIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> ShiftViewController {
    return DataConfirmationViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  func webBrowserView(alternativeTitle: String?,
                      eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol {
    return WebBrowserViewControllerTheme2(alternativeTitle: alternativeTitle,
                                          uiConfiguration: uiConfig,
                                          presenter: eventHandler)
  }

  // MARK: - Manage card
  func manageCardView(mode: ShiftCardModuleMode,
                      presenter: ManageShiftCardEventHandler) -> ManageShiftCardViewControllerProtocol {
     return ManageShiftCardViewControllerTheme2(mode: mode, uiConfiguration: uiConfig, presenter: presenter)
  }

  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> ShiftViewController {
     return FundingSourceSelectorViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  func cardSettingsView(presenter: CardSettingsPresenterProtocol) -> CardSettingsViewControllerProtocol {
     return CardSettingsViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  func kycView(presenter: KYCPresenterProtocol) -> KYCViewControllerProtocol {
   return KYCViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
  }

  func cardMonthlyView(presenter: CardMonthlyStatsPresenterProtocol) -> ShiftViewController {
     return CardMonthlyStatsViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func transactionListView(presenter: TransactionListPresenterProtocol) -> ShiftViewController {
    return TransactionListViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func notificationPreferencesView(presenter: NotificationPreferencesPresenterProtocol) -> ShiftViewController {
    return NotificationPreferencesViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  func setPinView(presenter: SetPinPresenterProtocol) -> ShiftViewController {
    return SetPinViewControllerThemeTwo(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
  }

  func voIPView(presenter: VoIPPresenterProtocol) -> ShiftViewController {
    return VoIPViewController(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
  }

  func monthlyStatementsListView(presenter: MonthlyStatementsListPresenterProtocol) -> ShiftViewController {
    return MonthlyStatementsListViewController(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
  }

  func monthlyStatementsReportView(presenter: MonthlyStatementsReportPresenterProtocol) -> ShiftViewController {
    return MonthlyStatementsReportViewController(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
  }

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> ShiftViewController {
    return PhysicalCardActivationViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func physicalCardActivationSucceedView(uiConfig: UIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
      -> PhysicalCardActivationSucceedViewControllerProtocol {
    return PhysicalCardActivationSucceedViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: ShiftCardTransactionDetailsPresenterProtocol)
    -> ShiftCardTransactionDetailsViewControllerProtocol {
    return ShiftCardTransactionDetailsViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

}
