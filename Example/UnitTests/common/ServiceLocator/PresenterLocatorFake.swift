//
//  PresenterLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class PresenterLocatorFake: PresenterLocatorProtocol {
    lazy var fullScreenDisclaimerPresenterSpy = FullScreenDisclaimerPresenterSpy()
    func fullScreenDisclaimerPresenter() -> FullScreenDisclaimerPresenterProtocol {
        return fullScreenDisclaimerPresenterSpy
    }

    lazy var countrySelectorPresenterSpy = CountrySelectorPresenterSpy()
    func countrySelectorPresenter() -> CountrySelectorPresenterProtocol {
        return countrySelectorPresenterSpy
    }

    lazy var authPresenterSpy = AuthPresenterSpy()
    func authPresenter(authConfig _: AuthModuleConfig, uiConfig _: UIConfig) -> AuthPresenterProtocol {
        return authPresenterSpy
    }

    func verifyPhonePresenter() -> VerifyPhonePresenterProtocol {
        Swift.fatalError("verifyPhonePresenter() has not been implemented")
    }

    func verifyBirthDatePresenter() -> VerifyBirthDatePresenterProtocol {
        Swift.fatalError("verifyBirthDayPresenter() has not been implemented")
    }

    lazy var externalOauthPresenterSpy = ExternalOAuthPresenterSpy()
    func externalOAuthPresenter(config _: ExternalOAuthModuleConfig) -> ExternalOAuthPresenterProtocol {
        return externalOauthPresenterSpy
    }

    // MARK: - Biometrics

    lazy var createPasscodePresenterSpy = CreatePasscodePresenterSpy()
    func createPasscodePresenter() -> CreatePasscodePresenterProtocol {
        return createPasscodePresenterSpy
    }

    lazy var verifyPasscodePresenterSpy = VerifyPasscodePresenterSpy()
    func verifyPasscodePresenter(config _: VerifyPasscodePresenterConfig) -> VerifyPasscodePresenterProtocol {
        return verifyPasscodePresenterSpy
    }

    lazy var changePasscodePresenterSpy = ChangePasscodePresenterSpy()
    func changePasscodePresenter() -> ChangePasscodePresenterProtocol {
        return changePasscodePresenterSpy
    }

    lazy var biometricPermissionPresenterSpy = BiometricPermissionPresenterSpy()
    func biometricPermissionPresenter() -> BiometricPermissionPresenterProtocol {
        return biometricPermissionPresenterSpy
    }

    lazy var issueCardPresenterSpy = IssueCardPresenterSpy()
    func issueCardPresenter(router _: IssueCardRouter,
                            interactor _: IssueCardInteractorProtocol,
                            configuration _: IssueCardActionConfiguration?) -> IssueCardPresenterProtocol
    {
        return issueCardPresenterSpy
    }

    lazy var waitListPresenterSpy = WaitListPresenterSpy()
    func waitListPresenter(config _: WaitListActionConfiguration?) -> CardApplicationWaitListPresenterProtocol {
        return waitListPresenterSpy
    }

    lazy var cardWaitListPresenterSpy = CardWaitListPresenterSpy()
    func cardWaitListPresenter(config _: WaitListActionConfiguration?) -> CardWaitListPresenterProtocol {
        return cardWaitListPresenterSpy
    }

    lazy var serverMaintenanceErrorPresenterSpy = ServerMaintenanceErrorPresenterSpy()
    func serverMaintenanceErrorPresenter() -> ServerMaintenanceErrorPresenterProtocol {
        return serverMaintenanceErrorPresenterSpy
    }

    func accountSettingsPresenter(config _: AccountSettingsPresenterConfig) -> AccountSettingsPresenterProtocol {
        Swift.fatalError("accountSettingsPresenter(config:) has not been implemented")
    }

    lazy var contentPresenterPresenterSpy = ContentPresenterPresenterSpy()
    func contentPresenterPresenter() -> ContentPresenterPresenterProtocol {
        return contentPresenterPresenterSpy
    }

    lazy var dataConfirmationPresenterSpy = DataConfirmationPresenterSpy()
    func dataConfirmationPresenter() -> DataConfirmationPresenterProtocol {
        return dataConfirmationPresenterSpy
    }

    lazy var webBrowserPresenterSpy = WebBrowserPresenterSpy()
    func webBrowserPresenter() -> WebBrowserPresenterProtocol {
        return webBrowserPresenterSpy
    }

    // MARK: - Manage card

    func manageCardPresenter(config _: ManageCardPresenterConfig) -> ManageCardPresenterProtocol {
        Swift.fatalError("manageCardPresenter(config:) has not been implemented")
    }

    func fundingSourceSelectorPresenter(config _: FundingSourceSelectorPresenterConfig) -> FundingSourceSelectorPresenterProtocol {
        Swift.fatalError("fundingSourceSelectorPresenter() has not been implemented")
    }

    lazy var cardSettingsPresenterSpy = CardSettingsPresenterSpy()
    func cardSettingsPresenter(card _: Card, config _: CardSettingsPresenterConfig, emailRecipients _: [String?],
                               uiConfig _: UIConfig) -> CardSettingsPresenterProtocol
    {
        return cardSettingsPresenterSpy
    }

    func kycPresenter() -> KYCPresenterProtocol {
        Swift.fatalError("kycPresenter() has not been implemented")
    }

    lazy var cardMonthlyStatsPresenterSpy = CardMonthlyStatsPresenterSpy()
    func cardMonthlyStatsPresenter() -> CardMonthlyStatsPresenterProtocol {
        return cardMonthlyStatsPresenterSpy
    }

    lazy var transactionListPresenterSpy = TransactionListPresenterSpy()
    func transactionListPresenter(config _: TransactionListModuleConfig) -> TransactionListPresenterProtocol {
        transactionListPresenterSpy
    }

    func transactionListPresenter(
        config _: TransactionListModuleConfig,
        transactionListEvents _: TransactionListEvents?
    ) -> TransactionListPresenterProtocol {
        return transactionListPresenterSpy
    }

    lazy var notificationPreferencesPresenterSpy = NotificationPreferencesPresenterSpy()
    func notificationPreferencesPresenter() -> NotificationPreferencesPresenterProtocol {
        return notificationPreferencesPresenterSpy
    }

    lazy var setPinPresenterSpy = SetCodePresenterSpy()
    func setCodePresenter() -> SetCodePresenterProtocol {
        return setPinPresenterSpy
    }

    lazy var voIPPresenterSpy = VoIPPresenterSpy()
    func voIPPresenter() -> VoIPPresenterProtocol {
        return voIPPresenterSpy
    }

    lazy var monthlyStatementsListPresenterSpy = MonthlyStatementsListPresenterSpy()
    func monthlyStatementsListPresenter() -> MonthlyStatementsListPresenterProtocol {
        return monthlyStatementsListPresenterSpy
    }

    lazy var monthlyStatementsReportPresenterSpy = MonthlyStatementsReportPresenterSpy()
    func monthlyStatementsReportPresenter() -> MonthlyStatementsReportPresenterProtocol {
        return monthlyStatementsReportPresenterSpy
    }

    // MARK: - Physical card activation

    func physicalCardActivationPresenter() -> PhysicalCardActivationPresenterProtocol {
        Swift.fatalError("physicalCardActivationPresenter() has not been implemented")
    }

    lazy var physicalCardActivationSucceedPresenterSpy = PhysicalCardActivationSucceedPresenterSpy()
    func physicalCardActivationSucceedPresenter() -> PhysicalCardActivationSucceedPresenterProtocol {
        return physicalCardActivationSucceedPresenterSpy
    }

    // MARK: - Transaction Details

    func transactionDetailsPresenter() -> AptoCardTransactionDetailsPresenterProtocol {
        Swift.fatalError("transactionDetailsPresenter() has not been implemented")
    }
}
