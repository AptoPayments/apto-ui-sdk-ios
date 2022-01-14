//
//  VerifyPhoneModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 12/10/2016.
//
//

import AptoSDK
import UIKit

protocol VerifyPhoneModuleProtocol: UIModuleProtocol {
    var onVerificationPassed: ((_ verifyPhoneModule: VerifyPhoneModule,
                                _ verification: Verification) -> Void)? { get set }
}

class VerifyPhoneModule: UIModule, VerifyPhoneModuleProtocol {
    private let verificationType: VerificationParams<PhoneNumber, Verification>
    private var presenter: VerifyPhonePresenterProtocol?
    open var onVerificationPassed: ((_ verifyPhoneModule: VerifyPhoneModule, _ verification: Verification) -> Void)?

    init(serviceLocator: ServiceLocatorProtocol, verificationType: VerificationParams<PhoneNumber, Verification>) {
        self.verificationType = verificationType
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let presenter = serviceLocator.presenterLocator.verifyPhonePresenter()
        let interactor = serviceLocator.interactorLocator.verifyPhoneInteractor(verificationType: verificationType,
                                                                                dataReceiver: presenter)
        presenter.interactor = interactor
        presenter.router = self
        let viewController = serviceLocator.viewLocator.pinVerificationView(presenter: presenter)
        presenter.view = viewController
        addChild(viewController: viewController, completion: completion)
        self.presenter = presenter
    }
}

extension VerifyPhoneModule: VerifyPhoneRouterProtocol {
    func closeTappedInVerifyPhone() {
        close()
    }

    func phoneVerificationPassed(verification: Verification) {
        onVerificationPassed?(self, verification)
    }
}
