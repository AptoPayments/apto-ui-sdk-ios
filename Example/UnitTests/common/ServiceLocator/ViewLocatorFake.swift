//
//  ViewLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class ViewLocatorFake: ViewLocatorProtocol {
  private let uiConfig = ModelDataProvider.provider.uiConfig

  func fullScreenDisclaimerView(uiConfig: UIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController {
    return FullScreenDisclaimerViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func countrySelectorView(presenter: CountrySelectorPresenterProtocol) -> ShiftViewController {
    return CountrySelectorViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  func authView(uiConfig: UIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    return AuthViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol {
    Swift.fatalError("pinVerificationView(presenter:) has not been implemented")
  }

  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol {
    Swift.fatalError("verifyBirthDateView(presenter:) has not been implemented")
  }

  func externalOAuthView(uiConfiguration: UIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    return ExternalOAuthViewControllerTheme1(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
  }

  func issueCardView(uiConfig: UIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
    return IssueCardViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func waitListView(presenter: WaitListPresenterProtocol) -> ShiftViewController {
    return WaitListViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func serverMaintenanceErrorView(uiConfig: UIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController {
    return ServerMaintenanceErrorViewControllerTheme1(uiConfig: uiConfig, eventHandler: eventHandler)
  }

  func accountsSettingsView(uiConfig: UIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol {
    Swift.fatalError("accountsSettingsView(uiConfig:presenter:) has not been implemented")
  }

  func contentPresenterView(uiConfig: UIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController {
    return ContentPresenterViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func dataConfirmationView(uiConfig: UIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> ShiftViewController {
    return DataConfirmationViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
  }

  func webBrowserView(alternativeTitle: String?,
                      eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol {
    return WebBrowserViewControllerTheme1(alternativeTitle: alternativeTitle,
                                          uiConfiguration: uiConfig,
                                          eventHandler: eventHandler)
  }

  // MARK: - Manage card
  func manageCardView(mode: ShiftCardModuleMode,
                      presenter: ManageShiftCardEventHandler) -> ManageShiftCardViewControllerProtocol {
    Swift.fatalError("manageCardView(mode:presenter:) has not been implemented")
  }

  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> ShiftViewController {
    Swift.fatalError("fundingSourceSelectorView(presenter:) has not been implemented")
  }

  func cardSettingsView(presenter: CardSettingsPresenterProtocol) -> CardSettingsViewControllerProtocol {
    Swift.fatalError("cardSettingsView(presenter:) has not been implemented")
  }

  func kycView(presenter: KYCPresenterProtocol) -> KYCViewControllerProtocol {
    Swift.fatalError("kycView(presenter:) has not been implemented")
  }

  func cardMonthlyView(presenter: CardMonthlyStatsPresenterProtocol) -> ShiftViewController {
    return CardMonthlyStatsViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func transactionListView(presenter: TransactionListPresenterProtocol) -> ShiftViewController {
    return TransactionListViewController(uiConfiguration: uiConfig, presenter: presenter)
  }

  func notificationPreferencesView(presenter: NotificationPreferencesPresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func setPinView(presenter: SetPinPresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func voIPView(presenter: VoIPPresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> ShiftViewController {
    Swift.fatalError("physicalCardActivation(presenter:) has not been implemented")
  }

  func physicalCardActivationSucceedView(uiConfig: UIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
    -> PhysicalCardActivationSucceedViewControllerProtocol {
      return PhysicalCardActivationSucceedViewControllerTheme1(uiConfiguration: uiConfig, presenter: presenter)
  }

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: ShiftCardTransactionDetailsPresenterProtocol)
    -> ShiftCardTransactionDetailsViewControllerProtocol {
      Swift.fatalError("transactionDetailsView(presenter:) has not been implemented")
  }
}
