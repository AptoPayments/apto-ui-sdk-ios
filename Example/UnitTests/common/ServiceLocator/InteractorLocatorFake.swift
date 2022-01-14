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
    func fullScreenDisclaimerInteractor(disclaimer _: Content) -> FullScreenDisclaimerInteractorProtocol {
        return fullScreenDisclaimerInteractorSpy
    }

    lazy var countrySelectorInteractorFake = CountrySelectorInteractorFake()
    func countrySelectorInteractor(countries _: [Country]) -> CountrySelectorInteractorProtocol {
        return countrySelectorInteractorFake
    }

    lazy var authInteractorSpy = AuthInteractorSpy()
    func authInteractor(initialUserData _: DataPointList, authConfig _: AuthModuleConfig,
                        dataReceiver _: AuthDataReceiver, initializationData _: InitializationData?) -> AuthInteractorProtocol
    {
        return authInteractorSpy
    }

    func verifyPhoneInteractor(verificationType _: VerificationParams<PhoneNumber, Verification>,
                               dataReceiver _: VerifyPhoneDataReceiver) -> VerifyPhoneInteractorProtocol
    {
        Swift.fatalError("verifyPhoneInteractor(verificationType:dataReceiver:) has not been implemented")
    }

    func verifyBirthDateInteractor(verificationType _: VerificationParams<BirthDate, Verification>,
                                   dataReceiver _: VerifyBirthDateDataReceiver) -> VerifyBirthDateInteractorProtocol
    {
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
    func issueCardInteractor(application _: CardApplication, initializationData _: InitializationData?) -> IssueCardInteractorProtocol {
        return issueCardInteractorFake
    }

    lazy var waitListInteractorFake = WaitListInteractorFake()
    func waitListInteractor(application _: CardApplication) -> WaitListInteractorProtocol {
        return waitListInteractorFake
    }

    lazy var cardWaitListInteractorFake = CardWaitListInteractorFake()
    func cardWaitListInteractor(card _: Card) -> CardWaitListInteractorProtocol {
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
    func contentPresenterInteractor(content _: Content) -> ContentPresenterInteractorProtocol {
        return contentProviderInteractorFake
    }

    lazy var dataConfirmationInteractorFake = DataConfirmationInteractorFake()
    func dataConfirmationInteractor(userData _: DataPointList) -> DataConfirmationInteractorProtocol {
        return dataConfirmationInteractorFake
    }

    lazy var webBrowserInteractorSpy = WebBrowserInteractorSpy()
    func webBrowserInteractor(url _: URL,
                              headers _: [String: String]?,
                              dataReceiver _: WebBrowserDataReceiverProtocol) -> WebBrowserInteractorProtocol
    {
        return webBrowserInteractorSpy
    }

    // MARK: - Manage card

    func manageCardInteractor(card _: Card) -> ManageCardInteractorProtocol {
        Swift.fatalError("manageCardInteractor(card:) has not been implemented")
    }

    func fundingSourceSelector(card _: Card) -> FundingSourceSelectorInteractorProtocol {
        Swift.fatalError("fundingSourceSelector(card:) has not been implemented")
    }

    lazy var cardSettingsInteractorFake = CardSettingsInteractorFake()
    func cardSettingsInteractor() -> CardSettingsInteractorProtocol {
        return cardSettingsInteractorFake
    }

    func kycInteractor(card _: Card) -> KYCInteractorProtocol {
        Swift.fatalError("kycInteractor(card:) has not been implemented")
    }

    lazy var cardMonthlyStatsInteractorSpy = CardMonthlyStatsInteractorSpy()
    func cardMonthlyStatsInteractor(card _: Card) -> CardMonthlyStatsInteractorProtocol {
        return cardMonthlyStatsInteractorSpy
    }

    lazy var transactionListInteractorSpy = TransactionListInteractorSpy()
    func transactionListInteractor(card _: Card) -> TransactionListInteractorProtocol {
        return transactionListInteractorSpy
    }

    lazy var notificationPreferencesInteractorFake = NotificationPreferencesInteractorFake()
    func notificationPreferencesInteractor() -> NotificationPreferencesInteractorProtocol {
        return notificationPreferencesInteractorFake
    }

    lazy var setPinInteractorFake = SetCodeInteractorFake()
    func setPinInteractor(card _: Card) -> SetCodeInteractorProtocol {
        return setPinInteractorFake
    }

    lazy var setPassCodeInteractorFake = SetCodeInteractorFake()
    func setPassCodeInteractor(card _: Card, verification _: Verification?) -> SetCodeInteractorProtocol {
        return setPassCodeInteractorFake
    }

    lazy var voIPInteractorFake = VoIPInteractorFake()
    func voIPInteractor(card _: Card, actionSource _: VoIPActionSource) -> VoIPInteractorProtocol {
        return voIPInteractorFake
    }

    lazy var monthlyStatementsListFake = MonthlyStatementsListInteractorFake()
    func monthlyStatementsListInteractor() -> MonthlyStatementsListInteractorProtocol {
        return monthlyStatementsListFake
    }

    lazy var monthlyStatementsReportInteractorFake = MonthlyStatementsReportInteractorFake()
    func monthlyStatementsReportInteractor(month _: Month, downloaderProvider _: FileDownloaderProvider)
        -> MonthlyStatementsReportInteractorProtocol
    {
        return monthlyStatementsReportInteractorFake
    }

    // MARK: - Physical card activation

    func physicalCardActivationInteractor(card _: Card) -> PhysicalCardActivationInteractorProtocol {
        Swift.fatalError("physicalCardActivationInteractor(card:session:) has not been implemented")
    }

    lazy var physicalCardActivationSucceedInteractorFake = PhysicalCardActivationSucceedInteractorFake()
    func physicalCardActivationSucceedInteractor(card: Card) -> PhysicalCardActivationSucceedInteractorProtocol {
        physicalCardActivationSucceedInteractorFake.card = card
        return physicalCardActivationSucceedInteractorFake
    }

    // MARK: - Transaction Details

    func transactionDetailsInteractor(transaction _: Transaction) -> AptoCardTransactionDetailsInteractorProtocol {
        Swift.fatalError("transactionDetailsInteractor(transaction:) has not been implemented")
    }
}
