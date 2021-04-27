//
//  InteractorLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class InteractorLocatorFake: InteractorLocatorProtocol {
  lazy var fullScreenDisclaimerInteractorSpy = FullScreenDisclaimerInteractorSpy()
  func fullScreenDisclaimerInteractor(disclaimer: Content) -> FullScreenDisclaimerInteractorProtocol {
    return fullScreenDisclaimerInteractorSpy
  }

  lazy var countrySelectorInteractorFake = CountrySelectorInteractorFake()
  func countrySelectorInteractor(countries: [Country]) -> CountrySelectorInteractorProtocol {
    return countrySelectorInteractorFake
  }

  lazy var authInteractorSpy = AuthInteractorSpy()
  func authInteractor(initialUserData: DataPointList, authConfig: AuthModuleConfig,
                      dataReceiver: AuthDataReceiver, initializationData: InitializationData?) -> AuthInteractorProtocol {
    return authInteractorSpy
  }

  func verifyPhoneInteractor(verificationType: VerificationParams<PhoneNumber, Verification>,
                             dataReceiver: VerifyPhoneDataReceiver) -> VerifyPhoneInteractorProtocol {
    Swift.fatalError("verifyPhoneInteractor(verificationType:dataReceiver:) has not been implemented")
  }

  func verifyBirthDateInteractor(verificationType: VerificationParams<BirthDate, Verification>,
                                 dataReceiver: VerifyBirthDateDataReceiver) -> VerifyBirthDateInteractorProtocol {
    Swift.fatalError("verifyBirthDateInteractor(verificationType:dataReceiver:) has not been implemented")
  }

  lazy var externalOauthInteractorSpy = ExternalOAuthInteractorSpy()
  func externalOAuthInteractor() -> ExternalOAuthInteractorProtocol {
    return externalOauthInteractorSpy
  }

  // MARK: - Biometrics
  lazy var createPasscodeInteractorFake = CreatePasscodeInteractorFake()
  func createPasscodeInteractor() -> CreatePasscodeInteractorProtocol {
    return createPasscodeInteractorFake
  }

  lazy var verifyPasscodeInteractorFake = VerifyPasscodeInteractorFake()
  func verifyPasscodeInteractor() -> VerifyPasscodeInteractorProtocol {
    return verifyPasscodeInteractorFake
  }

  lazy var changePasscodeInteractorFake = ChangePasscodeInteractorFake()
  func changePasscodeInteractor() -> ChangePasscodeInteractorProtocol {
    return changePasscodeInteractorFake
  }

  lazy var biometricPermissionInteractorFake = BiometricPermissionInteractorFake()
  func biometricPermissionInteractor() -> BiometricPermissionInteractorProtocol {
    return biometricPermissionInteractorFake
  }

  lazy var issueCardInteractorFake = IssueCardInteractorFake()
  func issueCardInteractor(application: CardApplication, initializationData: InitializationData?) -> IssueCardInteractorProtocol {
    return issueCardInteractorFake
  }

  lazy var waitListInteractorFake = WaitListInteractorFake()
  func waitListInteractor(application: CardApplication) -> WaitListInteractorProtocol {
    return waitListInteractorFake
  }

  lazy var cardWaitListInteractorFake = CardWaitListInteractorFake()
  func cardWaitListInteractor(card: Card) -> CardWaitListInteractorProtocol {
    return cardWaitListInteractorFake
  }

  lazy var serverMaintenanceErrorInteractorSpy = ServerMaintenanceErrorInteractorSpy()
  func serverMaintenanceErrorInteractor() -> ServerMaintenanceErrorInteractorProtocol {
    return serverMaintenanceErrorInteractorSpy
  }

  func accountSettingsInteractor() -> AccountSettingsInteractorProtocol {
    Swift.fatalError("accountSettingsInteractor() has not been implemented")
  }

  lazy var contentProviderInteractorFake = ContentPresenterInteractorFake()
  func contentPresenterInteractor(content: Content) -> ContentPresenterInteractorProtocol {
    return contentProviderInteractorFake
  }

  lazy var dataConfirmationInteractorFake = DataConfirmationInteractorFake()
  func dataConfirmationInteractor(userData: DataPointList) -> DataConfirmationInteractorProtocol {
    return dataConfirmationInteractorFake
  }

  lazy var webBrowserInteractorSpy = WebBrowserInteractorSpy()
  func webBrowserInteractor(url: URL,
                            headers: [String: String]?,
                            dataReceiver: WebBrowserDataReceiverProtocol) -> WebBrowserInteractorProtocol {
    return webBrowserInteractorSpy
  }

  // MARK: - Manage card
  func manageCardInteractor(card: Card) -> ManageCardInteractorProtocol {
    Swift.fatalError("manageCardInteractor(card:) has not been implemented")
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorInteractorProtocol {
    Swift.fatalError("fundingSourceSelector(card:) has not been implemented")
  }

  lazy var cardSettingsInteractorFake = CardSettingsInteractorFake()
  func cardSettingsInteractor() -> CardSettingsInteractorProtocol {
    return cardSettingsInteractorFake
  }

  func kycInteractor(card: Card) -> KYCInteractorProtocol {
    Swift.fatalError("kycInteractor(card:) has not been implemented")
  }

  lazy var cardMonthlyStatsInteractorSpy = CardMonthlyStatsInteractorSpy()
  func cardMonthlyStatsInteractor(card: Card) -> CardMonthlyStatsInteractorProtocol {
    return cardMonthlyStatsInteractorSpy
  }

  lazy var transactionListInteractorSpy = TransactionListInteractorSpy()
  func transactionListInteractor(card: Card) -> TransactionListInteractorProtocol {
    return transactionListInteractorSpy
  }

  lazy var notificationPreferencesInteractorFake = NotificationPreferencesInteractorFake()
  func notificationPreferencesInteractor() -> NotificationPreferencesInteractorProtocol {
    return notificationPreferencesInteractorFake
  }

  lazy var setPinInteractorFake = SetCodeInteractorFake()
  func setPinInteractor(card: Card) -> SetCodeInteractorProtocol {
    return setPinInteractorFake
  }

  lazy var setPassCodeInteractorFake = SetCodeInteractorFake()
  func setPassCodeInteractor(card: Card, verification: Verification?) -> SetCodeInteractorProtocol {
    return setPassCodeInteractorFake
  }

  lazy var voIPInteractorFake = VoIPInteractorFake()
  func voIPInteractor(card: Card, actionSource: VoIPActionSource) -> VoIPInteractorProtocol {
    return voIPInteractorFake
  }

  lazy var monthlyStatementsListFake = MonthlyStatementsListInteractorFake()
  func monthlyStatementsListInteractor() -> MonthlyStatementsListInteractorProtocol {
    return monthlyStatementsListFake
  }

  lazy var monthlyStatementsReportInteractorFake = MonthlyStatementsReportInteractorFake()
  func monthlyStatementsReportInteractor(month: Month, downloaderProvider: FileDownloaderProvider)
    -> MonthlyStatementsReportInteractorProtocol {
      return monthlyStatementsReportInteractorFake
  }

  // MARK: - Physical card activation
  func physicalCardActivationInteractor(card: Card) -> PhysicalCardActivationInteractorProtocol {
    Swift.fatalError("physicalCardActivationInteractor(card:session:) has not been implemented")
  }

  lazy var physicalCardActivationSucceedInteractorFake = PhysicalCardActivationSucceedInteractorFake()
  func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol {
    physicalCardActivationSucceedInteractorFake.card = card
    return physicalCardActivationSucceedInteractorFake
  }

  // MARK: - Transaction Details
  func transactionDetailsInteractor(transaction: Transaction) -> ShiftCardTransactionDetailsInteractorProtocol {
    Swift.fatalError("transactionDetailsInteractor(transaction:) has not been implemented")
  }
}
