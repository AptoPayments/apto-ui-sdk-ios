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
  private var uiTheme: UITheme {
    guard let theme = serviceLocator.uiConfig?.uiTheme else {
      return .theme1
    }
    return theme
  }
  private var uiConfig: UIConfig {
    return serviceLocator.uiConfig
  }

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fullScreenDisclaimerView(uiConfig: UIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return FullScreenDisclaimerViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return FullScreenDisclaimerViewControllerTheme2(uiConfiguration: uiConfig, eventHandler: eventHandler)
    }
  }

  func countrySelectorView(presenter: CountrySelectorPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return CountrySelectorViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func authView(uiConfig: UIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return AuthViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return AuthViewControllerTheme2(uiConfiguration: uiConfig, eventHandler: eventHandler)
    }
  }

  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return PINVerificationViewControllerTheme1(uiConfig: uiConfig, presenter: presenter)
    case .theme2:
      return PINVerificationViewControllerTheme2(uiConfig: uiConfig, presenter: presenter)
    }
  }

  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return VerifyBirthDateViewControllerTheme1(uiConfig: uiConfig, presenter: presenter)
    case .theme2:
      return VerifyBirthDateViewControllerTheme2(uiConfig: uiConfig, presenter: presenter)
    }
  }

  func externalOAuthView(uiConfiguration: UIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return ExternalOAuthViewControllerTheme1(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
    case .theme2:
      return ExternalOAuthViewControllerTheme2(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
    }
  }

  func issueCardView(uiConfig: UIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return IssueCardViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return IssueCardViewControllerTheme2(uiConfiguration: uiConfig, presenter: eventHandler)
    }
  }

  func waitListView(presenter: WaitListPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return WaitListViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func serverMaintenanceErrorView(uiConfig: UIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController {
    switch uiTheme {
    case .theme1:
      return ServerMaintenanceErrorViewControllerTheme1(uiConfig: uiConfig, eventHandler: eventHandler)
    case .theme2:
      return ServerMaintenanceErrorViewControllerTheme2(uiConfig: uiConfig, eventHandler: eventHandler)
    }
  }

  func accountsSettingsView(uiConfig: UIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol {
    switch uiTheme {
    case .theme1:
      return AccountSettingsViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return AccountSettingsViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func contentPresenterView(uiConfig: UIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return ContentPresenterViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func dataConfirmationView(uiConfig: UIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1:
      return DataConfirmationViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return DataConfirmationViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func webBrowserView(alternativeTitle: String?,
                      eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return WebBrowserViewControllerTheme1(alternativeTitle: alternativeTitle,
                                            uiConfiguration: uiConfig,
                                            eventHandler: eventHandler)
    case .theme2:
      return WebBrowserViewControllerTheme2(alternativeTitle: alternativeTitle,
                                            uiConfiguration: uiConfig,
                                            presenter: eventHandler)
    }
  }

  // MARK: - Manage card
  func manageCardView(mode: ShiftCardModuleMode,
                      presenter: ManageShiftCardEventHandler) -> ManageShiftCardViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return ManageShiftCardViewControllerTheme1(mode: mode, uiConfiguration: uiConfig, eventHandler: presenter)
    case .theme2:
      return ManageShiftCardViewControllerTheme2(mode: mode, uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return FundingSourceSelectorViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func cardSettingsView(presenter: CardSettingsPresenterProtocol) -> CardSettingsViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return CardSettingsViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return CardSettingsViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func kycView(presenter: KYCPresenterProtocol) -> KYCViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return KYCViewControllerTheme1(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    case .theme2:
      return KYCViewControllerTheme2(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func cardMonthlyView(presenter: CardMonthlyStatsPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return CardMonthlyStatsViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func transactionListView(presenter: TransactionListPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return TransactionListViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func notificationPreferencesView(presenter: NotificationPreferencesPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1:
      return NotificationPreferencesViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return NotificationPreferencesViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func setPinView(presenter: SetPinPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1:
      return SetPinViewControllerThemeOne(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    case .theme2:
      return SetPinViewControllerThemeTwo(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
    }
  }

  func voIPView(presenter: VoIPPresenterProtocol) -> ShiftViewController {
    return VoIPViewController(uiConfiguration: serviceLocator.uiConfig, presenter: presenter)
  }

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> ShiftViewController {
    switch uiTheme {
    case .theme1, .theme2:
      return PhysicalCardActivationViewController(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  func physicalCardActivationSucceedView(uiConfig: UIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
      -> PhysicalCardActivationSucceedViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return PhysicalCardActivationSucceedViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return PhysicalCardActivationSucceedViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: ShiftCardTransactionDetailsPresenterProtocol)
    -> ShiftCardTransactionDetailsViewControllerProtocol {
    switch uiTheme {
    case .theme1:
      return ShiftCardTransactionDetailsViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
    case .theme2:
      return ShiftCardTransactionDetailsViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }
  }

}
