//
//  AuthModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 12/12/2017.
//

import AptoSDK
import UIKit

class AuthModule: UIModule, AuthModuleProtocol {
    private let config: AuthModuleConfig
    private let initialUserData: DataPointList

    open var onExistingUser: ((_ authModule: AuthModule, _ user: AptoUser) -> Void)?

    fileprivate var verifyPhoneModule: VerifyPhoneModuleProtocol?
    fileprivate var verifyEmailModule: VerifyEmailModuleProtocol?
    fileprivate var verifyBirthDateModule: VerifyBirthDateModuleProtocol?
    fileprivate var authPresenter: AuthPresenterProtocol?

    private let initializationData: InitializationData?

    // MARK: - Module Initialization

    init(serviceLocator: ServiceLocatorProtocol,
         config: AuthModuleConfig,
         initialUserData: DataPointList, initializationData: InitializationData?)
    {
        self.config = config
        self.initialUserData = initialUserData
        self.initializationData = initializationData
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let viewController = buildAuthViewController(initialUserData, uiConfig: uiConfig, config: config)
        addChild(viewController: viewController, completion: completion)
    }

    // MARK: - Auth View Controller Handling

    fileprivate func buildAuthViewController(_ initialUserData: DataPointList,
                                             uiConfig: UIConfig,
                                             config: AuthModuleConfig) -> UIViewController
    {
        let presenter = serviceLocator.presenterLocator.authPresenter(authConfig: config, uiConfig: uiConfig)
        let interactor = serviceLocator
            .interactorLocator
            .authInteractor(initialUserData: initialUserData,
                            authConfig: config,
                            dataReceiver: presenter, initializationData: initializationData)
        let viewController = serviceLocator
            .viewLocator
            .authView(uiConfig: uiConfig, mode: config.mode, eventHandler: presenter)

        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = self
        presenter.analyticsManager = serviceLocator.analyticsManager
        authPresenter = presenter

        return viewController
    }

    // MARK: - AuthRouterProtocol protocol

    func returnExistingUser(_ user: AptoUser) {
        onExistingUser?(self, user)
    }

    func presentPhoneVerification(verificationType: VerificationParams<PhoneNumber, Verification>,
                                  completion: (Result<Verification, NSError>.Callback)?)
    {
        let verifyPhoneModule = serviceLocator.moduleLocator.verifyPhoneModule(verificationType: verificationType)
        verifyPhoneModule.onClose = { [weak self] _ in
            self?.popModule {
                self?.verifyPhoneModule = nil
            }
        }
        verifyPhoneModule.onVerificationPassed = { [weak self] _, verification in
            completion?(.success(verification))
            self?.verifyPhoneModule = nil
        }
        push(module: verifyPhoneModule, replacePrevious: replacePreviousModule) { _ in }
        self.verifyPhoneModule = verifyPhoneModule
    }

    func presentEmailVerification(verificationType: VerificationParams<Email, Verification>,
                                  completion: (Result<Verification, NSError>.Callback)?)
    {
        let verifyEmailModule = serviceLocator.moduleLocator.verifyEmailModule(verificationType: verificationType)
        verifyEmailModule.onClose = { [weak self] _ in
            self?.popModule {
                self?.verifyEmailModule = nil
            }
        }
        verifyEmailModule.onVerificationPassed = { [weak self] _, verification in
            completion?(.success(verification))
            self?.verifyEmailModule = nil
        }
        push(module: verifyEmailModule, replacePrevious: replacePreviousModule) { _ in }
        self.verifyEmailModule = verifyEmailModule
    }

    func presentBirthdateVerification(verificationType: VerificationParams<BirthDate, Verification>,
                                      completion: (Result<Verification, NSError>.Callback)?)
    {
        let verifyBirthDateModule = serviceLocator.moduleLocator.verifyBirthDateModule(verificationType: verificationType)
        verifyBirthDateModule.onClose = { [weak self] _ in
            self?.popModule {
                self?.verifyBirthDateModule = nil
            }
        }
        verifyBirthDateModule.onVerificationPassed = { [weak self] _, verification in
            completion?(.success(verification))
            self?.verifyBirthDateModule = nil
        }
        push(module: verifyBirthDateModule, replacePrevious: replacePreviousModule) { _ in }
        self.verifyBirthDateModule = verifyBirthDateModule
    }

    private var replacePreviousModule: Bool {
        let modules: [UIModuleProtocol?] = [verifyPhoneModule, verifyEmailModule, verifyBirthDateModule]
        let nonNilModules = modules.compactMap { $0 }
        return !nonNilModules.isEmpty
    }
}
