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
                                eventHandler: FullScreenDisclaimerEventHandler) -> UIViewController
  func countrySelectorView(presenter: CountrySelectorPresenterProtocol) -> ShiftViewController

  // MARK: - Auth
  func authView(uiConfig: UIConfig, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol
  func pinVerificationView(presenter: PINVerificationPresenter) -> PINVerificationViewControllerProtocol
  func verifyBirthDateView(presenter: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol
  func externalOAuthView(uiConfiguration: UIConfig,
                         eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController

  // MARK: - Biometrics
  func createPINView(presenter: CreatePINPresenterProtocol) -> ShiftViewController
  func verifyPINView(presenter: VerifyPINPresenterProtocol) -> ShiftViewController

  func issueCardView(uiConfig: UIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController
  func waitListView(presenter: WaitListPresenterProtocol) -> ShiftViewController
  func serverMaintenanceErrorView(uiConfig: UIConfig?,
                                  eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController
  func accountsSettingsView(uiConfig: UIConfig,
                            presenter: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol
  func contentPresenterView(uiConfig: UIConfig,
                            presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController
  func dataConfirmationView(uiConfig: UIConfig,
                            presenter: DataConfirmationPresenterProtocol) -> ShiftViewController
  func webBrowserView(alternativeTitle: String?,
                      eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol

  // MARK: - Manage card
  func manageCardView(mode: ShiftCardModuleMode,
                      presenter: ManageShiftCardEventHandler) -> ManageShiftCardViewControllerProtocol
  func fundingSourceSelectorView(presenter: FundingSourceSelectorPresenterProtocol) -> ShiftViewController
  func cardSettingsView(presenter: CardSettingsPresenterProtocol) -> CardSettingsViewControllerProtocol
  func kycView(presenter: KYCPresenterProtocol) -> KYCViewControllerProtocol
  func cardMonthlyView(presenter: CardMonthlyStatsPresenterProtocol) -> ShiftViewController
  func transactionListView(presenter: TransactionListPresenterProtocol) -> ShiftViewController
  func notificationPreferencesView(presenter: NotificationPreferencesPresenterProtocol) -> ShiftViewController
  func setPinView(presenter: SetPinPresenterProtocol) -> ShiftViewController
  func voIPView(presenter: VoIPPresenterProtocol) -> ShiftViewController
  func monthlyStatementsListView(presenter: MonthlyStatementsListPresenterProtocol) -> ShiftViewController
  func monthlyStatementsReportView(presenter: MonthlyStatementsReportPresenterProtocol) -> ShiftViewController

  // MARK: - Physical card activation
  func physicalCardActivation(presenter: PhysicalCardActivationPresenterProtocol) -> ShiftViewController
  func physicalCardActivationSucceedView(uiConfig: UIConfig,
                                         presenter: PhysicalCardActivationSucceedPresenterProtocol)
    -> PhysicalCardActivationSucceedViewControllerProtocol

  // MARK: - Transaction Details
  func transactionDetailsView(presenter: ShiftCardTransactionDetailsPresenterProtocol)
    -> ShiftCardTransactionDetailsViewControllerProtocol
}
