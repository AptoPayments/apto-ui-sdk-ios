//
//  InteractorLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import AptoSDK

protocol InteractorLocatorProtocol {
  func fullScreenDisclaimerInteractor(disclaimer: Content) -> FullScreenDisclaimerInteractorProtocol
  func countrySelectorInteractor(countries: [Country]) -> CountrySelectorInteractorProtocol

  // MARK: - Auth
  func authInteractor(initialUserData: DataPointList, authConfig: AuthModuleConfig,
                      dataReceiver: AuthDataReceiver) -> AuthInteractorProtocol
  func verifyPhoneInteractor(verificationType: VerificationParams<PhoneNumber, Verification>,
                             dataReceiver: VerifyPhoneDataReceiver) -> VerifyPhoneInteractorProtocol
  func verifyBirthDateInteractor(verificationType: VerificationParams<BirthDate, Verification>,
                                 dataReceiver: VerifyBirthDateDataReceiver) -> VerifyBirthDateInteractorProtocol
  func externalOAuthInteractor() -> ExternalOAuthInteractorProtocol

  // MARK: - Biometrics
  func createPasscodeInteractor() -> CreatePasscodeInteractorProtocol
  func verifyPasscodeInteractor() -> VerifyPasscodeInteractorProtocol
  func changePasscodeInteractor() -> ChangePasscodeInteractorProtocol
  func biometricPermissionInteractor() -> BiometricPermissionInteractorProtocol

  func issueCardInteractor(application: CardApplication) -> IssueCardInteractorProtocol
  func waitListInteractor(application: CardApplication) -> WaitListInteractorProtocol
  func cardWaitListInteractor(card: Card) -> CardWaitListInteractorProtocol
  func serverMaintenanceErrorInteractor() -> ServerMaintenanceErrorInteractorProtocol
  func accountSettingsInteractor() -> AccountSettingsInteractorProtocol
  func contentPresenterInteractor(content: Content) -> ContentPresenterInteractorProtocol
  func dataConfirmationInteractor(userData: DataPointList) -> DataConfirmationInteractorProtocol
  func webBrowserInteractor(url: URL, headers: [String: String]?,
                            dataReceiver: WebBrowserDataReceiverProtocol) -> WebBrowserInteractorProtocol

  // MARK: - Manage card
  func manageCardInteractor(card: Card) -> ManageCardInteractorProtocol
  func fundingSourceSelector(card: Card) -> FundingSourceSelectorInteractorProtocol
  func cardSettingsInteractor() -> CardSettingsInteractorProtocol
  func kycInteractor(card: Card) -> KYCInteractorProtocol
  func cardMonthlyStatsInteractor(card: Card) -> CardMonthlyStatsInteractorProtocol
  func transactionListInteractor(card: Card) -> TransactionListInteractorProtocol
  func notificationPreferencesInteractor() -> NotificationPreferencesInteractorProtocol
  func setPinInteractor(card: Card) -> SetPinInteractorProtocol
  func voIPInteractor(card: Card, actionSource: VoIPActionSource) -> VoIPInteractorProtocol
  func monthlyStatementsListInteractor() -> MonthlyStatementsListInteractorProtocol
  func monthlyStatementsReportInteractor(month: Month, downloaderProvider: FileDownloaderProvider)
    -> MonthlyStatementsReportInteractorProtocol

  // MARK: - Physical card activation
  func physicalCardActivationInteractor(card: Card) -> PhysicalCardActivationInteractorProtocol
  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol

  // MARK: - Transaction Details
  func transactionDetailsInteractor(transaction: Transaction) -> ShiftCardTransactionDetailsInteractorProtocol
}
