//
// PhysicalCardActivationModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-10.
//

import AptoSDK
import Foundation

class PhysicalCardActivationModule: UIModule, PhysicalCardActivationModuleProtocol {
    private let card: Card
    private let caller: PhoneCallerProtocol
    private var presenter: PhysicalCardActivationPresenterProtocol?

    init(serviceLocator: ServiceLocatorProtocol, card: Card, phoneCaller: PhoneCallerProtocol) {
        self.card = card
        caller = phoneCaller
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let viewController = buildViewController()
        completion(.success(viewController))
    }

    func show(url: URL) {
        // useSafari is a must in this case to be able to handle mailto: links
        showExternal(url: url, useSafari: true)
    }

    func call(url: URL, completion: @escaping () -> Void) {
        caller.call(phoneNumberURL: url, from: self, completion: completion)
    }

    func cardActivationFinish() {
        finish()
    }

    private func buildViewController() -> AptoViewController {
        let interactor = serviceLocator.interactorLocator.physicalCardActivationInteractor(card: card)
        let presenter = serviceLocator.presenterLocator.physicalCardActivationPresenter()
        let viewController = serviceLocator.viewLocator.physicalCardActivation(presenter: presenter)
        presenter.router = self
        presenter.interactor = interactor
        presenter.analyticsManager = serviceLocator.analyticsManager
        self.presenter = presenter
        return viewController
    }
}
