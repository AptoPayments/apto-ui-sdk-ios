//
//  ViewLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//

import UIKit
import AptoSDK

// The methods of this protocol expected will return a compound data type consisting in a UIViewController and a given
// protocol. The reason behind that is that the swift compiler do not support this construction:
//
// protocol ViewControllerProtocol where Self: UIViewController {}
//
// That statement will compile but the app will crash in runtime whenever a UIViewController is expected.
protocol ViewLocatorProtocol {
  func fullScreenDisclaimerView(uiConfig: UIConfig,
                                eventHandler: FullScreenDisclaimerEventHandler,
                                disclaimerTitle: String,
                                callToActionTitle: String,
                                cancelActionTitle: String) -> UIViewController
  func countrySelectorView(presenter: CountrySelectorPresenterProtocol) -> AptoViewController

  // MARK: - Auth
  func authView(uiConfig: UIConfig, mode: AptoUISDKMode, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol
  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol
  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol
  func externalOAuthView(uiConfiguration: UIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController

  // MARK: - Biometrics
  func createPasscodeView(presenter: CreatePasscodePresenterProtocol) -> AptoViewController
  func verifyPasscodeView(presenter: VerifyPasscodePresenterProtocol) -> AptoViewController
  func changePasscodeView(presenter: ChangePasscodePresenterProtocol) -> AptoViewController
  func biometricPermissionView(presenter: BiometricPermissionPresenterProtocol) -> AptoViewController

  func issueCardView(uiConfig: UIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController
  func waitListView(presenter: WaitListPresenterProtocol) -> AptoViewController
  func serverMaintenanceErrorView(uiConfig: UIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController
  func accountsSettingsView(uiConfig: UIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol
  func contentPresenterView(uiConfig: UIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController
  func dataConfirmationView(uiConfig: UIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> AptoViewController
  func webBrowserView(alternativeTitle: String?,
                      eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol

  // MARK: - Manage card
  func manageCardView(mode: AptoUISDKMode, presenter: ManageCardEventHandler) -> ManageCardViewControllerProtocol
  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> AptoViewController
  func cardSettingsView(presenter: CardSettingsPresenterProtocol) -> CardSettingsViewControllerProtocol
  func kycView(presenter: KYCPresenterProtocol) -> KYCViewControllerProtocol
  func cardMonthlyView(presenter: CardMonthlyStatsPresenterProtocol) -> AptoViewController
  func transactionListView(presenter: TransactionListPresenterProtocol) -> AptoViewController
  func notificationPreferencesView(presenter: NotificationPreferencesPresenterProtocol) -> AptoViewController
  func setCodeView(presenter: SetCodePresenterProtocol, texts: SetCodeViewControllerTexts) -> AptoViewController
  func voIPView(presenter: VoIPPresenterProtocol) -> AptoViewController
  func monthlyStatementsListView(presenter: MonthlyStatementsListPresenterProtocol) -> AptoViewController
  func monthlyStatementsReportView(presenter: MonthlyStatementsReportPresenterProtocol) -> AptoViewController

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> AptoViewController
  func physicalCardActivationSucceedView(uiConfig: UIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
    -> PhysicalCardActivationSucceedViewControllerProtocol

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: AptoCardTransactionDetailsPresenterProtocol)
    -> AptoCardTransactionDetailsViewControllerProtocol
}
