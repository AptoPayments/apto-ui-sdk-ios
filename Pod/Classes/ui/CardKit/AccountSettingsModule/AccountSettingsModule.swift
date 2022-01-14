//
//  AccountSettingsModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//

import AptoSDK
import UIKit

class AccountSettingsModule: UIModule {
    private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
    private var mailSender: MailSender?
    private var presenter: AccountSettingsPresenterProtocol?
    private var notificationPreferencesModule: NotificationPreferencesModuleProtocol?

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        platform.fetchContextConfiguration { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(contextConfiguration):
                self.projectConfiguration = contextConfiguration.projectConfiguration
                let viewController = self.buildAccountSettingsViewController(uiConfig: self.uiConfig)
                self.addChild(viewController: viewController, completion: completion)
            }
        }
    }

    fileprivate func buildAccountSettingsViewController(uiConfig: UIConfig) -> AccountSettingsViewProtocol {
        let isNotificationPreferencesEnabled = platform.isFeatureEnabled(.showNotificationPreferences)
        let authManager = serviceLocator.systemServicesLocator.authenticationManager()
        let isChangePINEnabled = authManager.canChangeCode()
        let isAuthEnabled = platform.currentPCIAuthenticationType == .pinOrBiometrics ||
            platform.currentPCIAuthenticationType == .biometrics
        let biometryType = isAuthEnabled ? authManager.biometryType : .none
        let config = AccountSettingsPresenterConfig(showNotificationPreferences: isNotificationPreferencesEnabled,
                                                    showChangePIN: isChangePINEnabled, biometryType: biometryType)
        let presenter = serviceLocator.presenterLocator.accountSettingsPresenter(config: config)
        let interactor = serviceLocator.interactorLocator.accountSettingsInteractor()
        let viewController = serviceLocator.viewLocator.accountsSettingsView(uiConfig: uiConfig, presenter: presenter)
        presenter.router = self
        presenter.interactor = interactor
        presenter.analyticsManager = serviceLocator.analyticsManager
        self.presenter = presenter
        return viewController
    }
}

extension AccountSettingsModule: AccountSettingsRouterProtocol {
    func closeFromAccountSettings() {
        close()
    }

    func contactTappedInAccountSettings() {
        let mailSender = MailSender()
        self.mailSender = mailSender
        if mailSender.canSendEmail() {
            mailSender.sendMessageWith(subject: "email.support.subject".podLocalized(),
                                       message: "",
                                       recipients: [projectConfiguration.supportEmailAddress])
        } else {
            let gmailSender = GmailSender(recipient: String(projectConfiguration.supportEmailAddress ?? ""),
                                          subject: "email.support.subject".podLocalized())
            if gmailSender.canSendEmail() {
                gmailSender.sendMessage()
            } else {
                UIApplication.topViewController()?
                    .showMessage("account_settings.help.email_not_configured".podLocalized(),
                                 uiConfig: nil)
            }
        }
    }

    func notificationsTappedInAccountSettings() {
        let module = serviceLocator.moduleLocator.notificationPreferencesModule()
        module.onClose = { [unowned self] _ in
            self.popModule { self.notificationPreferencesModule = nil }
        }
        notificationPreferencesModule = module
        push(module: module) { _ in }
    }

    func showMonthlyStatements() {
        let module = serviceLocator.moduleLocator.monthlyStatementsList()
        module.onClose = { [unowned self] _ in
            self.popModule {}
        }
        push(module: module) { _ in }
    }

    func showChangePasscode() {
        let module = serviceLocator.moduleLocator.changePasscodeModule()
        module.onFinish = { [unowned self] _ in
            self.dismissModule { [unowned self] in
                self.show(message: "biometric.change_pin.success.message".podLocalized(),
                          title: "biometric.change_pin.success.title".podLocalized(), isError: false)
            }
        }
        module.onClose = { [unowned self] _ in
            self.dismissModule {}
        }
        present(module: module) { _ in }
    }
}
