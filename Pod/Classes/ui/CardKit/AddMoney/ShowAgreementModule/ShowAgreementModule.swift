//
//  ShowAgreementModule.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 4/2/21.
//

import Foundation
import AptoSDK


class ShowAgreementModule: UIModule {
    private let disclaimer: Content
    private let actionConfirmer: ActionConfirmer.Type
    private let analyticsManager: AnalyticsServiceProtocol?

    init(serviceLocator: ServiceLocatorProtocol,
         disclaimer: Content,
         actionConfirmer: ActionConfirmer.Type,
         analyticsManager: AnalyticsServiceProtocol?) {
        self.disclaimer = disclaimer
        self.actionConfirmer = actionConfirmer
        self.analyticsManager = analyticsManager
        super.init(serviceLocator: serviceLocator)
    }
    
    override func initialize(completion: @escaping (Result<UIViewController, NSError>) -> Void) {
        let module = buildFullScreenDisclaimerModule()
        addChild(module: module, completion: completion)
    }
    
    private func buildFullScreenDisclaimerModule() -> FullScreenDisclaimerModuleProtocol {
        let module = serviceLocator.moduleLocator.fullScreenDisclaimerModule(disclaimer: disclaimer)
        module.onDisclaimerAgreed = disclaimerAgreed
        return module
    }

    private func disclaimerAgreed(module: UIModuleProtocol) {
        showLoadingSpinner()
        serviceLocator
            .platform
            .acceptBankAccountAgreements(AgreementRequest.agreementsACH) { [weak self] result in
                switch result {
                case .success:
                    self?.finish()
                case .failure(let error):
                    self?.show(error: error)
                }
                self?.hideLoadingSpinner()
        }
    }
    
    private func confirmClose(onConfirm: @escaping () -> Void) {
        onConfirm()
    }
}
