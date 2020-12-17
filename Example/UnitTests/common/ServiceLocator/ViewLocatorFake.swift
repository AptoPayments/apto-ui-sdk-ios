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
    return FullScreenDisclaimerViewControllerTheme2(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func countrySelectorView(presenter: CountrySelectorPresenterProtocol) -> ShiftViewController {
    return CountrySelectorViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  func authView(uiConfig: UIConfig, mode: AptoUISDKMode, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
    return AuthViewControllerTheme2(uiConfiguration: uiConfig, mode: mode, eventHandler: eventHandler)
  }

  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol {
    Swift.fatalError("pinVerificationView(presenter:) has not been implemented")
  }

  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol {
    Swift.fatalError("verifyBirthDateView(presenter:) has not been implemented")
  }

  func externalOAuthView(uiConfiguration: UIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController {
    return ExternalOAuthViewControllerTheme2(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
  }

  // MARK: - Biometrics
  func createPasscodeView(presenter: CreatePasscodePresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func verifyPasscodeView(presenter: VerifyPasscodePresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func changePasscodeView(presenter: ChangePasscodePresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func biometricPermissionView(presenter: BiometricPermissionPresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
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
    Swift.fatalError("accountsSettingsView(uiConfig:presenter:) has not been implemented")
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
  func manageCardView(mode: AptoUISDKMode, presenter: ManageCardEventHandler) -> ManageCardViewControllerProtocol {
    Swift.fatalError("manageCardView(mode:presenter:) has not been implemented")
  }

  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> ShiftViewController {
    Swift.fatalError("fundingSourceSelectorView(presenter:) has not been implemented")
  }

  func cardSettingsView(presenter: CardSettingsPresenterProtocol) -> CardSettingsViewControllerProtocol {
    return CardSettingsViewControllerDummy(uiConfiguration: uiConfig)
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

  func setCodeView(presenter: SetCodePresenterProtocol, texts: SetCodeViewControllerTexts) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func voIPView(presenter: VoIPPresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func monthlyStatementsListView(presenter: MonthlyStatementsListPresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  func monthlyStatementsReportView(presenter: MonthlyStatementsReportPresenterProtocol) -> ShiftViewController {
    return ShiftViewController(uiConfiguration: uiConfig)
  }

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> ShiftViewController {
    Swift.fatalError("physicalCardActivation(presenter:) has not been implemented")
  }

  func physicalCardActivationSucceedView(uiConfig: UIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
    -> PhysicalCardActivationSucceedViewControllerProtocol {
      return PhysicalCardActivationSucceedViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
  }

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: ShiftCardTransactionDetailsPresenterProtocol)
    -> ShiftCardTransactionDetailsViewControllerProtocol {
      Swift.fatalError("transactionDetailsView(presenter:) has not been implemented")
  }
}
