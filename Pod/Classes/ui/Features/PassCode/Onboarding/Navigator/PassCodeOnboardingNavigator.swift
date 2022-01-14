import AptoSDK
import Foundation

protocol PassCodeOnboardingNavigatorType: AnyObject {
    func navigateToVerifyPhone(verificationType: VerificationParams<PhoneNumber, Verification>,
                               completion: @escaping (UIModule, Verification) -> Void)
    func navigateToVerifyEmail(verificationType: VerificationParams<Email, Verification>,
                               completion: @escaping (UIModule, Verification) -> Void)
    func navigateToSetPassCode(card: Card, verification: Verification?, module: UIModule?,
                               completion: @escaping () -> Void)
    func close(completion: (() -> Void)?)
}

final class PassCodeOnboardingNavigator: PassCodeOnboardingNavigatorType {
    private var uiConfig: UIConfig
    private let from: UIViewController
    private let serviceLocator: ServiceLocatorProtocol
    private var verifyPhoneModule: VerifyPhoneModuleProtocol?
    private var verifyEmailModule: VerifyEmailModuleProtocol?
    private var setPassCodeModule: SetCodeModuleProtocol?

    init(from: UIViewController, uiConfig: UIConfig, serviceLocator: ServiceLocatorProtocol) {
        self.from = from
        self.uiConfig = uiConfig
        self.serviceLocator = serviceLocator
    }

    func navigateToVerifyPhone(verificationType: VerificationParams<PhoneNumber, Verification>,
                               completion: @escaping (UIModule, Verification) -> Void)
    {
        let verifyPhoneModule = serviceLocator.moduleLocator.verifyPhoneModule(verificationType: verificationType)
        verifyPhoneModule.onVerificationPassed = { module, verification in
            completion(module, verification)
        }
        verifyPhoneModule.onClose = { [weak self] module in
            module.dismissModule(animated: false) {
                self?.close(completion: nil)
            }
        }
        // swiftlint:disable force_cast
        from.present(module: verifyPhoneModule as! UIModule, leftButtonMode: .close, uiConfig: uiConfig) { _ in }
        // swiftlint:enable// swiftlint:enable force_unwrapping force_cast
        self.verifyPhoneModule = verifyPhoneModule
    }

    func navigateToVerifyEmail(verificationType: VerificationParams<Email, Verification>,
                               completion: @escaping (UIModule, Verification) -> Void)
    {
        let verifyEmailModule = serviceLocator.moduleLocator.verifyEmailModule(verificationType: verificationType)
        verifyEmailModule.onVerificationPassed = { module, verification in
            completion(module, verification)
        }
        verifyEmailModule.onClose = { [weak self] module in
            module.dismissModule(animated: false) {
                self?.close(completion: nil)
            }
        }
        // swiftlint:disable force_cast
        from.present(module: verifyEmailModule as! UIModule, leftButtonMode: .close, uiConfig: uiConfig) { _ in }
        // swiftlint:enable force_cast
        self.verifyEmailModule = verifyEmailModule
    }

    func navigateToSetPassCode(card: Card, verification: Verification?,
                               module: UIModule?, completion: @escaping () -> Void)
    {
        let setPassCodeModule = serviceLocator.moduleLocator.setPassCodeModule(card: card, verification: verification)
        setPassCodeModule.onFinish = { _ in
            completion()
        }
        setPassCodeModule.onClose = { [weak self] module in
            module.dismissModule(animated: false) {
                self?.close(completion: nil)
            }
        }
        if let module = module {
            module.push(module: setPassCodeModule, leftButtonMode: .close) { _ in }
        } else {
            // swiftlint:disable force_cast
            from.present(module: setPassCodeModule as! UIModule, leftButtonMode: .close, uiConfig: uiConfig) { _ in }
            // swiftlint:enable force_cast
        }
        self.setPassCodeModule = setPassCodeModule
    }

    func close(completion: (() -> Void)?) {
        from.dismiss(animated: true, completion: completion)
    }
}
