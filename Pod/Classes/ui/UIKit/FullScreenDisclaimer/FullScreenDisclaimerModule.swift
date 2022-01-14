//
//  FullScreenDisclaimerModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import AptoSDK
import Foundation

class FullScreenDisclaimerModule: UIModule, FullScreenDisclaimerModuleProtocol {
    private let disclaimer: Content
    private var presenter: FullScreenDisclaimerPresenterProtocol?

    var onDisclaimerAgreed: ((_ fullScreenDisclaimerModule: FullScreenDisclaimerModuleProtocol) -> Void)?
    private var disclaimerTitle: String
    private var callToActionTitle: String
    private var cancelActionTitle: String

    init(serviceLocator: ServiceLocatorProtocol,
         disclaimer: Content,
         disclaimerTitle: String,
         callToActionTitle: String,
         cancelActionTitle: String)
    {
        self.disclaimer = disclaimer
        self.disclaimerTitle = disclaimerTitle
        self.callToActionTitle = callToActionTitle
        self.cancelActionTitle = cancelActionTitle
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let viewController = buildFullScreenDisclaimerViewController(uiConfig)
        addChild(viewController: viewController, completion: completion)
    }

    private func buildFullScreenDisclaimerViewController(_ uiConfig: UIConfig) -> UIViewController {
        let presenter = serviceLocator.presenterLocator.fullScreenDisclaimerPresenter()
        let interactor = serviceLocator.interactorLocator.fullScreenDisclaimerInteractor(disclaimer: disclaimer)
        let viewController = serviceLocator.viewLocator.fullScreenDisclaimerView(uiConfig: uiConfig,
                                                                                 eventHandler: presenter,
                                                                                 disclaimerTitle: disclaimerTitle,
                                                                                 callToActionTitle: callToActionTitle,
                                                                                 cancelActionTitle: cancelActionTitle)
        presenter.interactor = interactor
        presenter.router = self
        presenter.analyticsManager = serviceLocator.analyticsManager
        self.presenter = presenter
        return viewController
    }
}

extension FullScreenDisclaimerModule: FullScreenDisclaimerRouterProtocol {
    func agreeTapped() {
        onDisclaimerAgreed?(self)
        finish()
    }
}
