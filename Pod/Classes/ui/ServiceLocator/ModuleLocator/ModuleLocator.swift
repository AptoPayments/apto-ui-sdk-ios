//
//  ModuleLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import AptoSDK

final class ModuleLocator: ModuleLocatorProtocol {
  private unowned let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol) {
    self.serviceLocator = serviceLocator
  }

  func fullScreenDisclaimerModule(disclaimer: Content,
                                  disclaimerTitle: String,
                                  callToActionTitle: String,
                                  cancelActionTitle: String) -> FullScreenDisclaimerModuleProtocol {
    return FullScreenDisclaimerModule(serviceLocator: serviceLocator,
                                      disclaimer: disclaimer,
                                      disclaimerTitle: disclaimerTitle,
                                      callToActionTitle: callToActionTitle,
                                      cancelActionTitle: cancelActionTitle)
  }

  func countrySelectorModule(countries: [Country]) -> CountrySelectorModuleProtocol {
    return CountrySelectorModule(serviceLocator: serviceLocator, countries: countries)
  }

  func authModule(authConfig: AuthModuleConfig, initialUserData: DataPointList, initializationData: InitializationData?) -> AuthModuleProtocol {
    return AuthModule(serviceLocator: serviceLocator, config: authConfig, initialUserData: initialUserData, initializationData: initializationData)
  }

  func verifyPhoneModule(verificationType: VerificationParams<PhoneNumber, Verification>) -> VerifyPhoneModuleProtocol {
    return VerifyPhoneModule(serviceLocator: serviceLocator, verificationType: verificationType)
  }

  func verifyEmailModule(verificationType: VerificationParams<Email, Verification>) -> VerifyEmailModuleProtocol {
    return VerifyEmailModule(serviceLocator: serviceLocator, verificationType: verificationType)
  }

  func verifyBirthDateModule(verificationType: VerificationParams<BirthDate, Verification>)
      -> VerifyBirthDateModuleProtocol {
    return VerifyBirthDateModule(serviceLocator: serviceLocator, verificationType: verificationType)
  }

  func externalOAuthModule(config: ExternalOAuthModuleConfig, uiConfig: UIConfig) -> ExternalOAuthModuleProtocol {
    return ExternalOAuthModule(serviceLocator: serviceLocator, config: config, uiConfig: uiConfig)
  }

  // MARK: - Biometrics
  func createPasscodeModule() -> CreatePasscodeModuleProtocol {
    return CreatePasscodeModule(serviceLocator: serviceLocator)
  }

  func verifyPasscodeModule() -> VerifyPasscodeModuleProtocol {
    return VerifyPasscodeModule(serviceLocator: serviceLocator)
  }

  func changePasscodeModule() -> ChangePasscodeModuleProtocol {
    return ChangePasscodeModule(serviceLocator: serviceLocator)
  }

  func biometricPermissionModule() -> BiometricPermissionModuleProtocol {
    return BiometricPermissionModule(serviceLocator: serviceLocator)
  }

  func cardProductSelectorModule() -> CardProductSelectorModuleProtocol {
    return CardProductSelectorModule(serviceLocator: serviceLocator)
  }

  func userDataCollectorModule(userRequiredData: RequiredDataPointList,
                               mode: UserDataCollectorFinalStepMode,
                               backButtonMode: UIViewControllerLeftButtonMode) -> UserDataCollectorModule {
    return UserDataCollectorModule(serviceLocator: serviceLocator,
                                   userRequiredData: userRequiredData,
                                   mode: mode,
                                   backButtonMode: backButtonMode)
  }

  func selectBalanceStoreModule(application: CardApplication) -> SelectBalanceStoreModuleProtocol {
    return SelectBalanceStoreModule(serviceLocator: serviceLocator,
                                    application: application,
                                    analyticsManager: serviceLocator.analyticsManager)
  }

  func showDisclaimerActionModule(workflowObject: WorkflowObject,
                                  workflowAction: WorkflowAction) -> ShowDisclaimerActionModuleProtocol {
    return ShowDisclaimerActionModule(serviceLocator: serviceLocator,
                                      workflowObject: workflowObject,
                                      workflowAction: workflowAction,
                                      actionConfirmer: UIAlertController.self,
                                      analyticsManager: serviceLocator.analyticsManager)
  }

  func verifyDocumentModule(workflowObject: WorkflowObject?) -> VerifyDocumentModule {
    return VerifyDocumentModule(serviceLocator: serviceLocator, workflowObject: workflowObject)
  }

    func issueCardModule(application: CardApplication, cardMetadata: String?) -> UIModuleProtocol {
        return IssueCardModule(serviceLocator: serviceLocator, application: application, cardMetadata: cardMetadata)
    }

  func waitListModule(application: CardApplication) -> WaitListModuleProtocol {
    return WaitListModule(serviceLocator: serviceLocator, cardApplication: application)
  }

  func cardWaitListModule(card: Card) -> CardWaitListModuleProtocol {
    return CardWaitListModule(serviceLocator: serviceLocator, card: card)
  }

  // MARK: - Errors
  func serverMaintenanceErrorModule() -> ServerMaintenanceErrorModuleProtocol {
    return ServerMaintenanceErrorModule(serviceLocator: serviceLocator)
  }

  func accountSettingsModule() -> UIModuleProtocol {
    return AccountSettingsModule(serviceLocator: serviceLocator)
  }

  func contentPresenterModule(content: Content, title: String) -> ContentPresenterModuleProtocol {
    return ContentPresenterModule(serviceLocator: serviceLocator, content: content, title: title)
  }

  func dataConfirmationModule(userData: DataPointList) -> DataConfirmationModuleProtocol {
    return DataConfirmationModule(serviceLocator: serviceLocator, userData: userData)
  }

  func webBrowserModule(url: URL, headers: [String: String]? = nil, alternativeTitle: String?) -> UIModuleProtocol {
    return WebBrowserModule(serviceLocator: serviceLocator,
                            url: url,
                            headers: headers,
                            alternativeTitle: alternativeTitle)
  }

  // MARK: - Manage card
  func manageCardModule(card: Card, mode: AptoUISDKMode) -> UIModuleProtocol {
    return ManageCardModule(serviceLocator: serviceLocator, card: card, mode: mode)
  }

  func fundingSourceSelector(card: Card) -> FundingSourceSelectorModuleProtocol {
    return FundingSourceSelectorModule(serviceLocator: serviceLocator, card: card)
  }

  func cardSettingsModule(card: Card) -> CardSettingsModuleProtocol {
    return CardSettingsModule(serviceLocator: serviceLocator, card: card, phoneCaller: PhoneCaller())
  }

  func cardMonthlyStatsModule(card: Card) -> CardMonthlyStatsModuleProtocol {
    return CardMonthlyStatsModule(serviceLocator: serviceLocator, card: card)
  }

  func transactionListModule(card: Card, config: TransactionListModuleConfig) -> TransactionListModuleProtocol {
    return TransactionListModule(serviceLocator: serviceLocator, card: card, config: config)
  }

  func notificationPreferencesModule() -> NotificationPreferencesModuleProtocol {
    return NotificationPreferencesModule(serviceLocator: serviceLocator)
  }

  func setPinModule(card: Card) -> SetCodeModuleProtocol {
    return SetPinModule(serviceLocator: serviceLocator, card: card)
  }

  func setPassCodeModule(card: Card, verification: Verification?) -> SetCodeModuleProtocol {
    return SetPassCodeModule(serviceLocator: serviceLocator, card: card, verification: verification)
  }

  func voIPModule(card: Card, actionSource: VoIPActionSource) -> VoIPModuleProtocol {
    return VoIPModule(serviceLocator: serviceLocator, card: card, actionSource: actionSource)
  }

  func monthlyStatementsList() -> MonthlyStatementsListModuleProtocol {
    return MonthlyStatementsListModule(serviceLocator: serviceLocator)
  }

  func monthlyStatementsReportModule(month: Month) -> MonthlyStatementsReportModuleProtocol {
    return MonthlyStatementsReportModule(serviceLocator: serviceLocator, month: month)
  }

  // MARK: - Physical card activation
  func physicalCardActivationModule(card: Card) -> PhysicalCardActivationModuleProtocol {
    return PhysicalCardActivationModule(serviceLocator: serviceLocator, card: card, phoneCaller: PhoneCaller())
  }

  func physicalCardActivationSucceedModule(card: Card) -> PhysicalCardActivationSucceedModuleProtocol {
    return PhysicalCardActivationSucceedModule(serviceLocator: serviceLocator, card: card, phoneCaller: PhoneCaller())
  }

    func showACHAccountAgreements(disclaimer: Content, cardId: String) -> ShowAgreementModule {
        ShowAgreementModule(serviceLocator: serviceLocator,
                            cardId: cardId, disclaimer: disclaimer,
                            actionConfirmer: UIAlertController.self,
                            analyticsManager: serviceLocator.analyticsManager)
    }
}
