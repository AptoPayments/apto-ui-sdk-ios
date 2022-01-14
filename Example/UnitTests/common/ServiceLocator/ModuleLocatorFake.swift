//
//  ModuleLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class ModuleLocatorFake: ModuleLocatorProtocol {
    private unowned let serviceLocator: ServiceLocatorProtocol

    init(serviceLocator: ServiceLocatorProtocol) {
        self.serviceLocator = serviceLocator
    }

    lazy var fullScreenDisclaimerModuleSpy: FullScreenDisclaimerModuleSpy = {
        FullScreenDisclaimerModuleSpy(serviceLocator: serviceLocator)
    }()

    func fullScreenDisclaimerModule(disclaimer _: Content,
                                    disclaimerTitle _: String,
                                    callToActionTitle _: String,
                                    cancelActionTitle _: String) -> FullScreenDisclaimerModuleProtocol
    {
        return fullScreenDisclaimerModuleSpy
    }

    lazy var countrySelectorModuleSpy: CountrySelectorModuleSpy = {
        CountrySelectorModuleSpy(serviceLocator: serviceLocator)
    }()

    func countrySelectorModule(countries _: [Country]) -> CountrySelectorModuleProtocol {
        return countrySelectorModuleSpy
    }

    func authModule(authConfig: AuthModuleConfig,
                    initialUserData: DataPointList, initializationData: InitializationData?) -> AuthModuleProtocol
    {
        return AuthModule(serviceLocator: serviceLocator,
                          config: authConfig,
                          initialUserData: initialUserData, initializationData: initializationData)
    }

    lazy var externalOauthModuleFake: ExternalOAuthModuleFake = {
        ExternalOAuthModuleFake(serviceLocator: serviceLocator)
    }()

    func externalOAuthModule(config _: ExternalOAuthModuleConfig, uiConfig _: UIConfig) -> ExternalOAuthModuleProtocol {
        return externalOauthModuleFake
    }

    // MARK: - Biometrics

    lazy var createPasscodeModuleSpy: CreatePasscodeModuleSpy = {
        CreatePasscodeModuleSpy(serviceLocator: serviceLocator)
    }()

    func createPasscodeModule() -> CreatePasscodeModuleProtocol {
        return createPasscodeModuleSpy
    }

    lazy var verifyPasscodeModuleSpy: VerifyPasscodeModuleSpy = {
        VerifyPasscodeModuleSpy(serviceLocator: serviceLocator)
    }()

    func verifyPasscodeModule() -> VerifyPasscodeModuleProtocol {
        return verifyPasscodeModuleSpy
    }

    lazy var changePasscodeModuleSpy: ChangePasscodeModuleSpy = {
        ChangePasscodeModuleSpy(serviceLocator: serviceLocator)
    }()

    func changePasscodeModule() -> ChangePasscodeModuleProtocol {
        return changePasscodeModuleSpy
    }

    lazy var biometricPermissionModuleFake = BiometricPermissionModuleFake(serviceLocator: serviceLocator)
    func biometricPermissionModule() -> BiometricPermissionModuleProtocol {
        return biometricPermissionModuleFake
    }

    func cardProductSelectorModule() -> CardProductSelectorModuleProtocol {
        Swift.fatalError("cardProductSelectorModule() has not been implemented")
    }

    lazy var verifyPhoneModuleSpy: VerifyPhoneModuleSpy = {
        VerifyPhoneModuleSpy(serviceLocator: serviceLocator)
    }()

    func verifyPhoneModule(verificationType _: VerificationParams<PhoneNumber, Verification>) -> VerifyPhoneModuleProtocol {
        return verifyPhoneModuleSpy
    }

    lazy var verifyEmailModuleSpy: VerifyEmailModuleSpy = {
        VerifyEmailModuleSpy(serviceLocator: serviceLocator)
    }()

    func verifyEmailModule(verificationType _: VerificationParams<Email, Verification>) -> VerifyEmailModuleProtocol {
        return verifyEmailModuleSpy
    }

    lazy var verifyBirthDateModuleSpy: VerifyBirthDateModuleSpy = {
        VerifyBirthDateModuleSpy(serviceLocator: serviceLocator)
    }()

    func verifyBirthDateModule(verificationType _: VerificationParams<BirthDate, Verification>)
        -> VerifyBirthDateModuleProtocol
    {
        return verifyBirthDateModuleSpy
    }

    func userDataCollectorModule(userRequiredData _: RequiredDataPointList,
                                 mode _: UserDataCollectorFinalStepMode,
                                 backButtonMode _: UIViewControllerLeftButtonMode) -> UserDataCollectorModule
    {
        Swift.fatalError("userDataCollectorModule(...) has not been implemented")
    }

    lazy var selectBalanceStoreModuleSpy: SelectBalanceStoreModuleProtocol = {
        SelectBalanceStoreModuleSpy(serviceLocator: serviceLocator)
    }()

    func selectBalanceStoreModule(application _: CardApplication) -> SelectBalanceStoreModuleProtocol {
        return selectBalanceStoreModuleSpy
    }

    lazy var showDisclaimerActionModuleSpy: ShowDisclaimerActionModuleProtocol = {
        ShowDisclaimerActionModuleSpy(serviceLocator: serviceLocator)
    }()

    func showDisclaimerActionModule(workflowObject _: WorkflowObject,
                                    workflowAction _: WorkflowAction) -> ShowDisclaimerActionModuleProtocol
    {
        return showDisclaimerActionModuleSpy
    }

    func verifyDocumentModule(workflowObject _: WorkflowObject?) -> VerifyDocumentModule {
        Swift.fatalError("verifyDocumentModule(workflowObject:) has not been implemented")
    }

    lazy var issueCardModuleSpy: IssueCardModuleSpy = {
        IssueCardModuleSpy(serviceLocator: serviceLocator)
    }()

    func issueCardModule(application _: CardApplication, initializationData _: InitializationData?) -> UIModuleProtocol {
        return issueCardModuleSpy
    }

    lazy var waitListModuleSpy: WaitListModuleSpy = {
        WaitListModuleSpy(serviceLocator: serviceLocator)
    }()

    func waitListModule(application _: CardApplication) -> WaitListModuleProtocol {
        return waitListModuleSpy
    }

    lazy var cardWaitListModuleSpy: CardWaitListModuleSpy = {
        CardWaitListModuleSpy(serviceLocator: serviceLocator)
    }()

    func cardWaitListModule(card _: Card) -> CardWaitListModuleProtocol {
        return cardWaitListModuleSpy
    }

    lazy var serverMaintenanceErrorModuleSpy: ServerMaintenanceErrorModuleSpy = {
        ServerMaintenanceErrorModuleSpy(serviceLocator: serviceLocator)
    }()

    func serverMaintenanceErrorModule() -> ServerMaintenanceErrorModuleProtocol {
        return serverMaintenanceErrorModuleSpy
    }

    func accountSettingsModule() -> UIModuleProtocol {
        Swift.fatalError("accountSettingsModule() has not been implemented")
    }

    lazy var contentPresenterModuleSpy: ContentPresenterModuleSpy = {
        ContentPresenterModuleSpy(serviceLocator: serviceLocator)
    }()

    func contentPresenterModule(content _: Content, title _: String) -> ContentPresenterModuleProtocol {
        return contentPresenterModuleSpy
    }

    lazy var dataConfirmationModuleSpy: DataConfirmationModuleSpy = {
        DataConfirmationModuleSpy(serviceLocator: serviceLocator)
    }()

    func dataConfirmationModule(userData _: DataPointList) -> DataConfirmationModuleProtocol {
        return dataConfirmationModuleSpy
    }

    lazy var webBrowserModuleSpy: WebBrowserModuleSpy = {
        WebBrowserModuleSpy(serviceLocator: serviceLocator)
    }()

    func webBrowserModule(url _: URL, headers _: [String: String]? = nil, alternativeTitle _: String?) -> UIModuleProtocol {
        return webBrowserModuleSpy
    }

    // MARK: - Manage card

    func manageCardModule(card _: Card, mode _: AptoUISDKMode) -> UIModuleProtocol {
        Swift.fatalError("manageCardModule(card:mode:) has not been implemented")
    }

    func fundingSourceSelector(card _: Card) -> FundingSourceSelectorModuleProtocol {
        Swift.fatalError("fundingSourceSelector(card:) has not been implemented")
    }

    func cardSettingsModule(card _: Card) -> CardSettingsModuleProtocol {
        Swift.fatalError("cardSettingsModule(card:) has not been implemented")
    }

    lazy var cardMonthlyStatsModuleSpy: CardMonthlyStatsModuleSpy = {
        CardMonthlyStatsModuleSpy(serviceLocator: serviceLocator)
    }()

    func cardMonthlyStatsModule(card _: Card) -> CardMonthlyStatsModuleProtocol {
        return cardMonthlyStatsModuleSpy
    }

    lazy var transactionListModuleSpy: TransactionListModuleSpy = {
        TransactionListModuleSpy(serviceLocator: serviceLocator)
    }()

    func transactionListModule(card _: Card, config _: TransactionListModuleConfig) -> TransactionListModuleProtocol {
        return transactionListModuleSpy
    }

    lazy var notificationPreferencesModuleSpy: NotificationPreferencesModuleSpy = {
        NotificationPreferencesModuleSpy(serviceLocator: serviceLocator)
    }()

    func notificationPreferencesModule() -> NotificationPreferencesModuleProtocol {
        return notificationPreferencesModuleSpy
    }

    lazy var setPinModuleSpy: SetCodeModuleSpy = {
        SetCodeModuleSpy(serviceLocator: serviceLocator)
    }()

    lazy var setPassCodeModuleSpy: SetCodeModuleSpy = {
        SetCodeModuleSpy(serviceLocator: serviceLocator)
    }()

    func setPassCodeModule(card _: Card, verification _: Verification?) -> SetCodeModuleProtocol {
        return setPassCodeModuleSpy
    }

    lazy var voIPModuleSpy: VoIPModuleSpy = {
        VoIPModuleSpy(serviceLocator: serviceLocator)
    }()

    func voIPModule(card _: Card, actionSource _: VoIPActionSource) -> VoIPModuleProtocol {
        return voIPModuleSpy
    }

    lazy var monthlyStatementsListModuleSpy: MonthlyStatementsListModuleSpy = {
        MonthlyStatementsListModuleSpy(serviceLocator: serviceLocator)
    }()

    func monthlyStatementsList() -> MonthlyStatementsListModuleProtocol {
        return monthlyStatementsListModuleSpy
    }

    lazy var monthlyStatementsReportModuleSpy: MonthlyStatementsReportModuleSpy = {
        MonthlyStatementsReportModuleSpy(serviceLocator: serviceLocator)
    }()

    func monthlyStatementsReportModule(month _: Month) -> MonthlyStatementsReportModuleProtocol {
        return monthlyStatementsReportModuleSpy
    }

    // MARK: - Physical card activation

    func physicalCardActivationModule(card _: Card) -> PhysicalCardActivationModuleProtocol {
        Swift.fatalError("physicalCardActivationModule(card:) has not been implemented")
    }

    lazy var physicalCardActivationSucceedModuleFake: PhysicalCardActivationSucceedModuleFake = {
        PhysicalCardActivationSucceedModuleFake(serviceLocator: serviceLocator)
    }()

    func physicalCardActivationSucceedModule(card _: Card) -> PhysicalCardActivationSucceedModuleProtocol {
        return physicalCardActivationSucceedModuleFake
    }

    func showACHAccountAgreements(disclaimer: Content, cardId: String) -> ShowAgreementModule {
        return ShowAgreementModule(serviceLocator: serviceLocator,
                                   cardId: cardId, disclaimer: disclaimer,
                                   actionConfirmer: UIAlertController.self,
                                   analyticsManager: nil)
    }
}
