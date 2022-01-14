//
// VerifyBirthDateContract.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 12/11/2018.
//

import AptoSDK

protocol VerifyBirthDateModuleProtocol: UIModuleProtocol {
    var onVerificationPassed: ((_ verifyBirthDateModule: VerifyBirthDateModule,
                                _ verification: Verification) -> Void)? { get set }
}

protocol VerifyBirthDateRouterProtocol: AnyObject {
    func closeTappedInVerifyBirthDate()
    func birthDateVerificationPassed(verification: Verification)
}

protocol VerifyBirthDateInteractorProtocol {
    func provideBirthDate()
    func submit(birthDate: Date)
}

protocol VerifyBirthDateEventHandler: AnyObject {
    func viewLoaded()
    func submitTapped(_ birthDate: Date)
    func closeTapped()
}

protocol VerifyBirthDateDataReceiver: AnyObject {
    func submitBirthDateError(_ error: NSError)
    func verificationStartError(_ error: NSError)
    func verificationReceived(_ verification: Verification)
    func verificationSucceeded(_ verification: Verification)
    func verificationFailed()
}

protocol VerifyBirthDatePresenterProtocol: VerifyBirthDateEventHandler, VerifyBirthDateDataReceiver {
    // swiftlint:disable implicitly_unwrapped_optional
    var interactor: VerifyBirthDateInteractorProtocol! { get set }
    var router: VerifyBirthDateRouterProtocol! { get set }
    var view: VerifyBirthDateViewProtocol! { get set }
    // swiftlint:enable implicitly_unwrapped_optional
}

protocol VerifyBirthDateViewProtocol: ViewControllerProtocol {
    func showWrongBirthDateErrorMessage()
    func showLoadingSpinner()
    func show(error: Error)
}

typealias VerifyBirthDateViewControllerProtocol = VerifyBirthDateViewProtocol & AptoViewController
