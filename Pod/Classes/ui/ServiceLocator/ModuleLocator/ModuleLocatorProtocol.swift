//
//  ModuleLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import AptoSDK

protocol ModuleLocatorProtocol {
  func fullScreenDisclaimerModule(disclaimer: Content,
                                  disclaimerTitle: String,
                                  callToActionTitle: String,
                                  cancelActionTitle: String) -> FullScreenDisclaimerModuleProtocol
  func countrySelectorModule(countries: [Country]) -> CountrySelectorModuleProtocol

  // MARK: - Auth module
    func authModule(authConfig: AuthModuleConfig, initialUserData: DataPointList, initializationData: InitializationData?) -> AuthModuleProtocol
  func verifyPhoneModule(verificationType: VerificationParams<PhoneNumber, Verification>) -> VerifyPhoneModuleProtocol
  func verifyEmailModule(verificationType: VerificationParams<Email, Verification>) -> VerifyEmailModuleProtocol
  func verifyBirthDateModule(verificationType: VerificationParams<BirthDate, Verification>)
      -> VerifyBirthDateModuleProtocol
  func externalOAuthModule(config: ExternalOAuthModuleConfig, uiConfig: UIConfig) -> ExternalOAuthModuleProtocol

  // MARK: - Biometrics
  func createPasscodeModule() -> CreatePasscodeModuleProtocol
  func verifyPasscodeModule() -> VerifyPasscodeModuleProtocol
  func changePasscodeModule() -> ChangePasscodeModuleProtocol
  func biometricPermissionModule() -> BiometricPermissionModuleProtocol

  func cardProductSelectorModule() -> CardProductSelectorModuleProtocol

  // MARK: - Data collector
  func userDataCollectorModule(userRequiredData: RequiredDataPointList,
                               mode: UserDataCollectorFinalStepMode,
                               backButtonMode: UIViewControllerLeftButtonMode) -> UserDataCollectorModule
  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol
  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol
  func verifyDocumentModule(workflowObject: WorkflowObject?) -> VerifyDocumentModule
  func issueCardModule(application: CardApplication, initializationData: InitializationData?) -> UIModuleProtocol
  func waitListModule(application: CardApplication) -> WaitListModuleProtocol
  func cardWaitListModule(card: Card) -> CardWaitListModuleProtocol

  // MARK: - Errors
  func serverMaintenanceErrorModule() -> ServerMaintenanceErrorModuleProtocol

  func accountSettingsModule() -> UIModuleProtocol
  func contentPresenterModule(content: Content, title: String) -> ContentPresenterModuleProtocol
  func dataConfirmationModule(userData: DataPointList) -> DataConfirmationModuleProtocol
  func webBrowserModule(url: URL, headers: [String: String]?, alternativeTitle: String?) -> UIModuleProtocol

  // MARK: - Manage card
  func manageCardModule(card: Card, mode: AptoUISDKMode) -> UIModuleProtocol
  func fundingSourceSelector(card: Card) -> FundingSourceSelectorModuleProtocol
  func cardSettingsModule(card: Card) -> CardSettingsModuleProtocol
  func cardMonthlyStatsModule(card: Card) -> CardMonthlyStatsModuleProtocol
  func transactionListModule(card: Card, config: TransactionListModuleConfig) -> TransactionListModuleProtocol
  func notificationPreferencesModule() -> NotificationPreferencesModuleProtocol
  func setPinModule(card: Card) -> SetCodeModuleProtocol
  func setPassCodeModule(card: Card, verification: Verification?) -> SetCodeModuleProtocol
  func voIPModule(card: Card, actionSource: VoIPActionSource) -> VoIPModuleProtocol
  func monthlyStatementsList() -> MonthlyStatementsListModuleProtocol
  func monthlyStatementsReportModule(month: Month) -> MonthlyStatementsReportModuleProtocol

  // MARK: - Physical card activation
  func physicalCardActivationModule(card: Card) -> PhysicalCardActivationModuleProtocol
  func physicalCardActivationSucceedModule(card: Card) -> PhysicalCardActivationSucceedModuleProtocol

    // MARK: ACH account agreements
    func showACHAccountAgreements(disclaimer: Content, cardId: String) -> ShowAgreementModule
}
