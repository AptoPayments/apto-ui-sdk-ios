//
//  InteractorLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import AptoSDK

final class InteractorLocator: InteractorLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fullScreenDisclaimerInteractor(disclaimer: Content) -> FullScreenDisclaimerInteractorProtocol {
    return FullScreenDisclaimerInteractor(disclaimer: disclaimer)
  }

  func countrySelectorInteractor(countries: [Country]) -> CountrySelectorInteractorProtocol {
    return CountrySelectorInteractor(countries: countries)
  }

  func authInteractor(initialUserData: DataPointList, authConfig: AuthModuleConfig,
                      dataReceiver: AuthDataReceiver) -> AuthInteractorProtocol {
    return AuthInteractor(platform: serviceLocator.platform, initialUserData: initialUserData, config: authConfig,
                          dataReceiver: dataReceiver)
  }

  func verifyPhoneInteractor(verificationType: VerificationParams<PhoneNumber, Verification>,
                             dataReceiver: VerifyPhoneDataReceiver) -> VerifyPhoneInteractorProtocol {
    return VerifyPhoneInteractor(platform: serviceLocator.platform, verificationType: verificationType,
                                 dataReceiver: dataReceiver)
  }

  func verifyBirthDateInteractor(verificationType: VerificationParams<BirthDate, Verification>,
                                 dataReceiver: VerifyBirthDateDataReceiver) -> VerifyBirthDateInteractorProtocol {
    return VerifyBirthDateInteractor(platform: serviceLocator.platform, verificationType: verificationType,
                                     dataReceiver: dataReceiver)
  }

  func externalOAuthInteractor() -> ExternalOAuthInteractorProtocol {
    return ExternalOAuthInteractor(platform: serviceLocator.platform)
  }

  func issueCardInteractor(application: CardApplication) -> IssueCardInteractorProtocol {
    return IssueCardInteractor(platform: serviceLocator.platform, application: application)
  }

  func waitListInteractor(application: CardApplication) -> WaitListInteractorProtocol {
    return WaitListInteractor(application: application, platform: serviceLocator.platform)
  }

  func cardWaitListInteractor(card: Card) -> CardWaitListInteractorProtocol {
    return CardWaitListInteractor(platform: serviceLocator.platform, card: card)
  }

  func serverMaintenanceErrorInteractor() -> ServerMaintenanceErrorInteractorProtocol {
    return ServerMaintenanceErrorInteractor(aptoPlatform: serviceLocator.platform)
  }

  func accountSettingsInteractor() -> AccountSettingsInteractorProtocol {
    return AccountSettingsInteractor(platform: serviceLocator.platform)
  }

  func contentPresenterInteractor(content: Content) -> ContentPresenterInteractorProtocol {
    return ContentPresenterInteractor(content: content)
  }

  func dataConfirmationInteractor(userData: DataPointList) -> DataConfirmationInteractorProtocol {
    return DataConfirmationInteractor(userData: userData)
  }

  func webBrowserInteractor(url: URL, headers: [String: String]?,
                            dataReceiver: WebBrowserDataReceiverProtocol) -> WebBrowserInteractorProtocol {
    return WebBrowserInteractor(url: url, headers: headers, dataReceiver: dataReceiver)
  }

  // MARK: - Manage card
  func manageCardInteractor(card: Card) -> ManageShiftCardInteractorProtocol {
    return ManageShiftCardInteractor(platform: serviceLocator.platform, card: card)
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorInteractorProtocol {
    return FundingSourceSelectorInteractor(card: card, platform: serviceLocator.platform)
  }

  func cardSettingsInteractor() -> CardSettingsInteractorProtocol {
    return CardSettingsInteractor(platform: serviceLocator.platform)
  }

  func kycInteractor(card: Card) -> KYCInteractorProtocol {
    return KYCInteractor(platform: serviceLocator.platform, card: card)
  }

  func cardMonthlyStatsInteractor(card: Card) -> CardMonthlyStatsInteractorProtocol {
    return CardMonthlyStatsInteractor(card: card, platform: serviceLocator.platform)
  }

  func transactionListInteractor(card: Card) -> TransactionListInteractorProtocol {
    return TransactionListInteractor(card: card, platform: serviceLocator.platform)
  }

  func notificationPreferencesInteractor() -> NotificationPreferencesInteractorProtocol {
    return NotificationPreferencesInteractor(platform: serviceLocator.platform)
  }

  func setPinInteractor(card: Card) -> SetPinInteractorProtocol {
    return SetPinInteractor(platform: serviceLocator.platform, card: card)
  }

  func voIPInteractor(card: Card, actionSource: VoIPActionSource) -> VoIPInteractorProtocol {
    return VoIPInteractor(platform: serviceLocator.platform, card: card, actionSource: actionSource)
  }

  func monthlyStatementsListInteractor() -> MonthlyStatementsListInteractorProtocol {
    return MonthlyStatementsListInteractor(platform: serviceLocator.platform)
  }

  func monthlyStatementsReportInteractor(report: MonthlyStatementReport,
                                         downloader: FileDownloader) -> MonthlyStatementsReportInteractorProtocol {
    return MonthlyStatementsReportInteractor(report: report, downloader: downloader)
  }

  // MARK: - Physical card activation
  func physicalCardActivationInteractor(card: Card) -> PhysicalCardActivationInteractorProtocol {
    return PhysicalCardActivationInteractor(card: card, platform: serviceLocator.platform)
  }

  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol {
    return PhysicalCardActivationSucceedInteractor(card: card)
  }

  // MARK: - Transaction Details
  func transactionDetailsInteractor(transaction: Transaction) -> ShiftCardTransactionDetailsInteractorProtocol {
    return ShiftCardTransactionDetailsInteractor(transaction: transaction)
  }
}
