//
//  ViewLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class ViewLocatorFake: ViewLocatorProtocol {
    private let uiConfig = ModelDataProvider.provider.uiConfig

    func fullScreenDisclaimerView(uiConfig: UIConfig,
                                  eventHandler: FullScreenDisclaimerEventHandler,
                                  disclaimerTitle: String,
                                  callToActionTitle: String,
                                  cancelActionTitle: String) -> UIViewController
    {
        return FullScreenDisclaimerViewControllerTheme2(uiConfiguration: uiConfig,
                                                        eventHandler: eventHandler,
                                                        disclaimerTitle: disclaimerTitle,
                                                        callToActionTitle: callToActionTitle,
                                                        cancelActionTitle: cancelActionTitle)
    }

    func countrySelectorView(presenter: CountrySelectorPresenterProtocol) -> AptoViewController {
        return CountrySelectorViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }

    func authView(uiConfig: UIConfig, mode: AptoUISDKMode, eventHandler: AuthEventHandler) -> AuthViewControllerProtocol {
        return AuthViewControllerTheme2(uiConfiguration: uiConfig, mode: mode, eventHandler: eventHandler)
    }

    func pinVerificationView(presenter _: PINVerificationPresenter) -> PINVerificationViewControllerProtocol {
        Swift.fatalError("pinVerificationView(presenter:) has not been implemented")
    }

    func verifyBirthDateView(presenter _: VerifyBirthDateEventHandler) -> VerifyBirthDateViewControllerProtocol {
        Swift.fatalError("verifyBirthDateView(presenter:) has not been implemented")
    }

    func externalOAuthView(uiConfiguration: UIConfig,
                           eventHandler: ExternalOAuthPresenterProtocol) -> UIViewController
    {
        return ExternalOAuthViewControllerTheme2(uiConfiguration: uiConfiguration, eventHandler: eventHandler)
    }

    // MARK: - Biometrics

    func createPasscodeView(presenter _: CreatePasscodePresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func verifyPasscodeView(presenter _: VerifyPasscodePresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func changePasscodeView(presenter _: ChangePasscodePresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func biometricPermissionView(presenter _: BiometricPermissionPresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func issueCardView(uiConfig: UIConfig, eventHandler: IssueCardPresenterProtocol) -> UIViewController {
        return IssueCardViewControllerTheme2(uiConfiguration: uiConfig, presenter: eventHandler)
    }

    func waitListView(presenter: WaitListPresenterProtocol) -> AptoViewController {
        return WaitListViewController(uiConfiguration: uiConfig, presenter: presenter)
    }

    func serverMaintenanceErrorView(uiConfig: UIConfig?,
                                    eventHandler: ServerMaintenanceErrorEventHandler) -> UIViewController
    {
        return ServerMaintenanceErrorViewControllerTheme2(uiConfig: uiConfig, eventHandler: eventHandler)
    }

    func accountsSettingsView(uiConfig _: UIConfig,
                              presenter _: AccountSettingsPresenterProtocol) -> AccountSettingsViewProtocol
    {
        Swift.fatalError("accountsSettingsView(uiConfig:presenter:) has not been implemented")
    }

    func contentPresenterView(uiConfig: UIConfig,
                              presenter: ContentPresenterPresenterProtocol) -> ContentPresenterViewController
    {
        return ContentPresenterViewController(uiConfiguration: uiConfig, presenter: presenter)
    }

    func dataConfirmationView(uiConfig: UIConfig,
                              presenter: DataConfirmationPresenterProtocol) -> AptoViewController
    {
        return DataConfirmationViewControllerTheme2(uiConfiguration: uiConfig, presenter: presenter)
    }

    func webBrowserView(alternativeTitle: String?,
                        eventHandler: WebBrowserEventHandlerProtocol) -> WebBrowserViewControllerProtocol
    {
        return WebBrowserViewControllerTheme2(alternativeTitle: alternativeTitle,
                                              uiConfiguration: uiConfig,
                                              presenter: eventHandler)
    }

    // MARK: - Manage card

    func manageCardView(mode _: AptoUISDKMode, presenter _: ManageCardEventHandler) -> ManageCardViewControllerProtocol {
        Swift.fatalError("manageCardView(mode:presenter:) has not been implemented")
    }

    func fundingSourceSelectorView(presenter _: FundingSourceSelectorPresenterProtocol) -> AptoViewController {
        Swift.fatalError("fundingSourceSelectorView(presenter:) has not been implemented")
    }

    func cardSettingsView(presenter _: CardSettingsPresenterProtocol) -> CardSettingsViewControllerProtocol {
        return CardSettingsViewControllerDummy(uiConfiguration: uiConfig)
    }

    func kycView(presenter _: KYCPresenterProtocol) -> KYCViewControllerProtocol {
        Swift.fatalError("kycView(presenter:) has not been implemented")
    }

    func cardMonthlyView(presenter: CardMonthlyStatsPresenterProtocol) -> AptoViewController {
        return CardMonthlyStatsViewController(uiConfiguration: uiConfig, presenter: presenter)
    }

    func transactionListView(presenter: TransactionListPresenterProtocol) -> AptoViewController {
        return TransactionListViewController(uiConfiguration: uiConfig, presenter: presenter)
    }

    func notificationPreferencesView(presenter _: NotificationPreferencesPresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func setCodeView(presenter _: SetCodePresenterProtocol, texts _: SetCodeViewControllerTexts) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func voIPView(presenter _: VoIPPresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func monthlyStatementsListView(presenter _: MonthlyStatementsListPresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    func monthlyStatementsReportView(presenter _: MonthlyStatementsReportPresenterProtocol) -> AptoViewController {
        return AptoViewController(uiConfiguration: uiConfig)
    }

    // MARK: - Physical card activation

    func physicalCardActivation(presenter _: PhysicalCardActivationPresenterProtocol) -> AptoViewController {
        Swift.fatalError("physicalCardActivation(presenter:) has not been implemented")
    }

    func physicalCardActivationSucceedView(uiConfig: UIConfig,
                                           card: Card,
                                           presenter: PhysicalCardActivationSucceedPresenterProtocol)
        -> PhysicalCardActivationSucceedViewControllerProtocol
    {
        return PhysicalCardActivationSucceedViewControllerTheme2(uiConfiguration: uiConfig, card: card, presenter: presenter)
    }

    // MARK: - Transaction Details

    func transactionDetailsView(presenter _: AptoCardTransactionDetailsPresenterProtocol)
        -> AptoCardTransactionDetailsViewControllerProtocol
    {
        Swift.fatalError("transactionDetailsView(presenter:) has not been implemented")
    }
}
