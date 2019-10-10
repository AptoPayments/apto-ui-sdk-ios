//
//  PresenterLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import AptoSDK

protocol PresenterLocatorProtocol {
  func fullScreenDisclaimerPresenter() -> FullScreenDisclaimerPresenterProtocol
  func countrySelectorPresenter() -> CountrySelectorPresenterProtocol

  // MARK: - Auth module
  func authPresenter(authConfig: AuthModuleConfig, uiConfig: UIConfig) -> AuthPresenterProtocol
  func verifyPhonePresenter() -> VerifyPhonePresenterProtocol
  func verifyBirthDatePresenter() -> VerifyBirthDatePresenterProtocol
  func externalOAuthPresenter(config: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol

  func issueCardPresenter(router: IssueCardRouter,
                          interactor: IssueCardInteractorProtocol,
                          configuration: IssueCardActionConfiguration?) -> IssueCardPresenterProtocol
  func waitListPresenter(config: WaitListActionConfiguration?) -> CardApplicationWaitListPresenterProtocol
  func cardWaitListPresenter(config: WaitListActionConfiguration?) -> CardWaitListPresenterProtocol
  func serverMaintenanceErrorPresenter() -> ServerMaintenanceErrorPresenterProtocol
  func accountSettingsPresenter(config: AccountSettingsPresenterConfig) -> AccountSettingsPresenterProtocol
  func contentPresenterPresenter() -> ContentPresenterPresenterProtocol
  func dataConfirmationPresenter() -> DataConfirmationPresenterProtocol
  func webBrowserPresenter() -> WebBrowserPresenterProtocol

  // MARK: - Manage card
  func manageCardPresenter(config: ManageShiftCardPresenterConfig) -> ManageShiftCardPresenterProtocol
  func fundingSourceSelectorPresenter(config: FundingSourceSelectorPresenterConfig) -> FundingSourceSelectorPresenterProtocol
  func cardSettingsPresenter(card: Card, config: CardSettingsPresenterConfig,  emailRecipients: [String?],
                             uiConfig: UIConfig) -> CardSettingsPresenterProtocol
  func kycPresenter() -> KYCPresenterProtocol
  func cardMonthlyStatsPresenter() -> CardMonthlyStatsPresenterProtocol
  func transactionListPresenter(config: TransactionListModuleConfig) -> TransactionListPresenterProtocol
  func notificationPreferencesPresenter() -> NotificationPreferencesPresenterProtocol
  func setPinPresenter() -> SetPinPresenterProtocol
  func voIPPresenter() -> VoIPPresenterProtocol
  func monthlyStatementsListPresenter() -> MonthlyStatementsListPresenterProtocol
  func monthlyStatementsReportPresenter() -> MonthlyStatementsReportPresenterProtocol

  // MARK: - Physical card activation
  func physicalCardActivationPresenter() -> PhysicalCardActivationPresenterProtocol
  func physicalCardActivationSucceedPresenter() -> PhysicalCardActivationSucceedPresenterProtocol

  // MARK: - Transaction Details
  func transactionDetailsPresenter() -> ShiftCardTransactionDetailsPresenterProtocol
}
