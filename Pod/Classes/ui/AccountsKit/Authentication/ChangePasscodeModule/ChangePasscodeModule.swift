//
//  ChangePasscodeModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//

import AptoSDK
import Foundation

class ChangePasscodeModule: UIModule, ChangePasscodeModuleProtocol {
    private var presenter: ChangePasscodePresenterProtocol?
    private let actionConfirmer: ActionConfirmer.Type

    init(serviceLocator: ServiceLocatorProtocol, actionConfirmer: ActionConfirmer.Type = UIAlertController.self) {
        self.actionConfirmer = actionConfirmer
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let viewController = buildViewController()
        completion(.success(viewController))
    }

    func showForgotPasscode() {
        let cancelTitle = "biometric.verify_pin.forgot.alert_cancel".podLocalized()
        actionConfirmer.confirm(title: "biometric.verify_pin.forgot.alert_title".podLocalized(),
                                message: "biometric.verify_pin.forgot.alert_message".podLocalized(),
                                okTitle: "biometric.verify_pin.forgot.alert_confirm".podLocalized(),
                                cancelTitle: cancelTitle) { [unowned self] action in
            guard let title = action.title, title != cancelTitle else { return }
            self.platform.logout()
        }
    }

    private func buildViewController() -> UIViewController {
        let presenter = serviceLocator.presenterLocator.changePasscodePresenter()
        let interactor = serviceLocator.interactorLocator.changePasscodeInteractor()
        let analyticsManager = serviceLocator.analyticsManager
        presenter.router = self
        presenter.interactor = interactor
        presenter.analyticsManager = analyticsManager
        self.presenter = presenter
        return serviceLocator.viewLocator.changePasscodeView(presenter: presenter)
    }
}
