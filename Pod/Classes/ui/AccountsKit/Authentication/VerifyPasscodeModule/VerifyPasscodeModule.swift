//
//  VerifyPasscodeModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import Foundation
import AptoSDK

class VerifyPasscodeModule: UIModule, VerifyPasscodeModuleProtocol {
  private var presenter: VerifyPasscodePresenterProtocol?
  private let actionConfirmer: ActionConfirmer.Type

  init(serviceLocator: ServiceLocatorProtocol, actionConfirmer: ActionConfirmer.Type = UIAlertController.self) {
    self.actionConfirmer = actionConfirmer
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    serviceLocator.platform.fetchContextConfiguration(false) { [unowned self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        let branding = contextConfiguration.projectConfiguration.branding
        let viewController = self.buildViewController(branding: branding)
        completion(.success(viewController))
      }
    }
  }

  func showForgotPIN() {
    let cancelTitle = "biometric.verify_pin.forgot.alert_cancel".podLocalized()
    actionConfirmer.confirm(title: "biometric.verify_pin.forgot.alert_title".podLocalized(),
                            message: "biometric.verify_pin.forgot.alert_message".podLocalized(),
                            okTitle: "biometric.verify_pin.forgot.alert_confirm".podLocalized(),
                            cancelTitle: cancelTitle) { [unowned self] action in
      guard let title = action.title, title != cancelTitle else { return }
      self.platform.logout()
    }
  }

  private func buildViewController(branding: Branding) -> UIViewController {
    let config = VerifyPasscodePresenterConfig(logoURL: branding.light.logoUrl)
    let presenter = serviceLocator.presenterLocator.verifyPasscodePresenter(config: config)
    let interactor = serviceLocator.interactorLocator.verifyPasscodeInteractor()
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.verifyPasscodeView(presenter: presenter)
  }
}
