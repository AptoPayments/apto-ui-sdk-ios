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
    return FullScreenDisclaimerModuleSpy(serviceLocator: serviceLocator)
  }()
  func fullScreenDisclaimerModule(disclaimer: Content) -> FullScreenDisclaimerModuleProtocol {
    return fullScreenDisclaimerModuleSpy
  }

  lazy var countrySelectorModuleSpy: CountrySelectorModuleSpy = {
    return CountrySelectorModuleSpy(serviceLocator: serviceLocator)
  }()
  func countrySelectorModule(countries: [Country]) -> CountrySelectorModuleProtocol {
    return countrySelectorModuleSpy
  }

  func authModule(authConfig: AuthModuleConfig,
                  initialUserData: DataPointList) -> AuthModuleProtocol {
    return AuthModule(serviceLocator: serviceLocator,
                      config: authConfig,
                      initialUserData: initialUserData)
  }

  lazy var externalOauthModuleFake: ExternalOAuthModuleFake = {
    return ExternalOAuthModuleFake(serviceLocator: serviceLocator)
  }()
  func externalOAuthModule(config: ExternalOAuthModuleConfig, uiConfig: UIConfig) -> ExternalOAuthModuleProtocol {
    return externalOauthModuleFake
  }

  // MARK: - Biometrics
  lazy var createPasscodeModuleSpy: CreatePasscodeModuleSpy = {
    return CreatePasscodeModuleSpy(serviceLocator: serviceLocator)
  }()
  func createPasscodeModule() -> CreatePasscodeModuleProtocol {
    return createPasscodeModuleSpy
  }

  lazy var verifyPasscodeModuleSpy: VerifyPasscodeModuleSpy = {
    return VerifyPasscodeModuleSpy(serviceLocator: serviceLocator)
  }()
  func verifyPasscodeModule() -> VerifyPasscodeModuleProtocol {
    return verifyPasscodeModuleSpy
  }

  lazy var changePasscodeModuleSpy: ChangePasscodeModuleSpy = {
    return ChangePasscodeModuleSpy(serviceLocator: serviceLocator)
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
    return VerifyPhoneModuleSpy(serviceLocator: serviceLocator)
  }()
  func verifyPhoneModule(verificationType: VerificationParams<PhoneNumber, Verification>) -> VerifyPhoneModuleProtocol {
    return verifyPhoneModuleSpy
  }

  lazy var verifyEmailModuleSpy: VerifyEmailModuleSpy = {
    return VerifyEmailModuleSpy(serviceLocator: serviceLocator)
  }()
  func verifyEmailModule(verificationType: VerificationParams<Email, Verification>) -> VerifyEmailModuleProtocol {
    return verifyEmailModuleSpy
  }

  lazy var verifyBirthDateModuleSpy: VerifyBirthDateModuleSpy = {
    return VerifyBirthDateModuleSpy(serviceLocator: serviceLocator)
  }()
  func verifyBirthDateModule(verificationType: VerificationParams<BirthDate, Verification>)
      -> VerifyBirthDateModuleProtocol {
    return verifyBirthDateModuleSpy
  }

  func userDataCollectorModule(userRequiredData: RequiredDataPointList,
                               mode: UserDataCollectorFinalStepMode,
                               backButtonMode: UIViewControllerLeftButtonMode) -> UserDataCollectorModule {
    Swift.fatalError("userDataCollectorModule(...) has not been implemented")
  }

  lazy var selectBalanceStoreModuleSpy: SelectBalanceStoreModuleProtocol = {
      return SelectBalanceStoreModuleSpy(serviceLocator: serviceLocator)
  }()
  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol {
    return selectBalanceStoreModuleSpy
  }

  lazy var showDisclaimerActionModuleSpy: ShowDisclaimerActionModuleProtocol = {
    return ShowDisclaimerActionModuleSpy(serviceLocator: serviceLocator)
  }()
  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol {
    return showDisclaimerActionModuleSpy
  }

  func verifyDocumentModule(workflowObject: WorkflowObject?) -> VerifyDocumentModule {
    Swift.fatalError("verifyDocumentModule(workflowObject:) has not been implemented")
  }

  lazy var issueCardModuleSpy: IssueCardModuleSpy = {
    return IssueCardModuleSpy(serviceLocator: serviceLocator)
  }()
  func issueCardModule(application: CardApplication) -> UIModuleProtocol {
    return issueCardModuleSpy
  }

  lazy var waitListModuleSpy: WaitListModuleSpy = {
    return WaitListModuleSpy(serviceLocator: serviceLocator)
  }()
  func waitListModule(application: CardApplication) -> WaitListModuleProtocol {
    return waitListModuleSpy
  }

  lazy var cardWaitListModuleSpy: CardWaitListModuleSpy = {
    return CardWaitListModuleSpy(serviceLocator: serviceLocator)
  }()
  func cardWaitListModule(card: Card) -> CardWaitListModuleProtocol {
    return cardWaitListModuleSpy
  }

  lazy var serverMaintenanceErrorModuleSpy: ServerMaintenanceErrorModuleSpy = {
    return ServerMaintenanceErrorModuleSpy(serviceLocator: serviceLocator)
  }()
  func serverMaintenanceErrorModule() -> ServerMaintenanceErrorModuleProtocol {
    return serverMaintenanceErrorModuleSpy
  }

  func accountSettingsModule() -> UIModuleProtocol {
    Swift.fatalError("accountSettingsModule() has not been implemented")
  }

  lazy var contentPresenterModuleSpy: ContentPresenterModuleSpy = {
    return ContentPresenterModuleSpy(serviceLocator: serviceLocator)
  }()
  func contentPresenterModule(content: Content, title: String) -> ContentPresenterModuleProtocol {
    return contentPresenterModuleSpy
  }

  lazy var dataConfirmationModuleSpy: DataConfirmationModuleSpy = {
    return DataConfirmationModuleSpy(serviceLocator: serviceLocator)
  }()
  func dataConfirmationModule(userData: DataPointList) -> DataConfirmationModuleProtocol {
    return dataConfirmationModuleSpy
  }

  lazy var webBrowserModuleSpy: WebBrowserModuleSpy = {
    return WebBrowserModuleSpy(serviceLocator: serviceLocator)
  }()
  func webBrowserModule(url: URL, headers: [String: String]? = nil, alternativeTitle: String?) -> UIModuleProtocol {
    return webBrowserModuleSpy
  }

  // MARK: - Manage card
  func manageCardModule(card: Card, mode: AptoUISDKMode) -> UIModuleProtocol {
    Swift.fatalError("manageCardModule(card:mode:) has not been implemented")
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorModuleProtocol {
    Swift.fatalError("fundingSourceSelector(card:) has not been implemented")
  }

  func cardSettingsModule(card: Card) -> CardSettingsModuleProtocol {
    Swift.fatalError("cardSettingsModule(card:) has not been implemented")
  }

  lazy var cardMonthlyStatsModuleSpy: CardMonthlyStatsModuleSpy = {
    return CardMonthlyStatsModuleSpy(serviceLocator: serviceLocator)
  }()
  func cardMonthlyStatsModule(card: Card) -> CardMonthlyStatsModuleProtocol {
    return cardMonthlyStatsModuleSpy
  }

  lazy var transactionListModuleSpy: TransactionListModuleSpy = {
    return TransactionListModuleSpy(serviceLocator: serviceLocator)
  }()
  func transactionListModule(card: Card, config: TransactionListModuleConfig) -> TransactionListModuleProtocol {
    return transactionListModuleSpy
  }

  lazy var notificationPreferencesModuleSpy: NotificationPreferencesModuleSpy = {
    return NotificationPreferencesModuleSpy(serviceLocator: serviceLocator)
  }()
  func notificationPreferencesModule() -> NotificationPreferencesModuleProtocol {
    return notificationPreferencesModuleSpy
  }

  lazy var setPinModuleSpy: SetPinModuleSpy = {
    return SetPinModuleSpy(serviceLocator: serviceLocator)
  }()
  func setPinModule(card: Card) -> SetPinModuleProtocol {
    return setPinModuleSpy
  }

  lazy var voIPModuleSpy: VoIPModuleSpy = {
    return VoIPModuleSpy(serviceLocator: serviceLocator)
  }()
  func voIPModule(card: Card, actionSource: VoIPActionSource) -> VoIPModuleProtocol {
    return voIPModuleSpy
  }

  lazy var monthlyStatementsListModuleSpy: MonthlyStatementsListModuleSpy = {
    return MonthlyStatementsListModuleSpy(serviceLocator: serviceLocator)
  }()
  func monthlyStatementsList() -> MonthlyStatementsListModuleProtocol {
    return monthlyStatementsListModuleSpy
  }

  lazy var monthlyStatementsReportModuleSpy: MonthlyStatementsReportModuleSpy = {
    return MonthlyStatementsReportModuleSpy(serviceLocator: serviceLocator)
  }()
  func monthlyStatementsReportModule(month: Month) -> MonthlyStatementsReportModuleProtocol {
    return monthlyStatementsReportModuleSpy
  }

  // MARK: - Physical card activation
  func physicalCardActivationModule(card: Card) -> PhysicalCardActivationModuleProtocol {
    Swift.fatalError("physicalCardActivationModule(card:) has not been implemented")
  }

  lazy var physicalCardActivationSucceedModuleFake: PhysicalCardActivationSucceedModuleFake = {
    return PhysicalCardActivationSucceedModuleFake(serviceLocator: serviceLocator)
  }()
  func physicalCardActivationSucceedModule(card: Card) -> PhysicalCardActivationSucceedModuleProtocol {
    return physicalCardActivationSucceedModuleFake
  }
}
