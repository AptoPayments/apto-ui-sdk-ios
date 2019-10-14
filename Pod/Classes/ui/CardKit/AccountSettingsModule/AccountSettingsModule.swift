//
//  AccountSettingsModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//

import UIKit
import AptoSDK

class AccountSettingsModule: UIModule {
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var mailSender: MailSender?
  private var presenter: AccountSettingsPresenterProtocol?
  private var notificationPreferencesModule: NotificationPreferencesModuleProtocol?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    platform.fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.projectConfiguration = contextConfiguration.projectConfiguration
        let viewController = self.buildAccountSettingsViewController(uiConfig: self.uiConfig)
        self.addChild(viewController: viewController, completion: completion)
      }
    }
  }

  fileprivate func buildAccountSettingsViewController(uiConfig: UIConfig) -> AccountSettingsViewProtocol {
    let isNotificationPreferencesEnabled = platform.isFeatureEnabled(.showNotificationPreferences)
    let isMonthlyStatementsEnabled = platform.isFeatureEnabled(.showMonthlyStatementsOption)
    let config = AccountSettingsPresenterConfig(showNotificationPreferences: isNotificationPreferencesEnabled,
                                                showMonthlyStatements: isMonthlyStatementsEnabled)
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
    mailSender.sendMessageWith(subject: "email.support.subject".podLocalized(),
                               message: "",
                               recipients: [self.projectConfiguration.supportEmailAddress])
  }

  func notificationsTappedInAccountSettings() {
    let module = serviceLocator.moduleLocator.notificationPreferencesModule()
    module.onClose = { [unowned self] _ in
      self.popModule { self.notificationPreferencesModule = nil }
    }
    self.notificationPreferencesModule = module
    push(module: module) { _ in }
  }

  func showMonthlyStatements() {
    let module = serviceLocator.moduleLocator.monthlyStatementsList()
    module.onClose = { [unowned self] _ in
      self.popModule {}
    }
    push(module: module) { _ in }
  }
}
