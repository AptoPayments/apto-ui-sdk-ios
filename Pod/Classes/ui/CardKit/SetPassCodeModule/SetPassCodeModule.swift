import AptoSDK
import Foundation

class SetPassCodeModule: UIModule, SetCodeModuleProtocol {
    private let card: Card
    private let verification: Verification?
    private var presenter: SetCodePresenterProtocol?

    init(serviceLocator: ServiceLocatorProtocol, card: Card, verification: Verification?) {
        self.card = card
        self.verification = verification
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        completion(.success(buildViewController()))
    }

    private func buildViewController() -> UIViewController {
        let presenter = serviceLocator.presenterLocator.setCodePresenter()
        let interactor = serviceLocator.interactorLocator.setPassCodeInteractor(card: card, verification: verification)
        let analyticsManager = serviceLocator.analyticsManager
        presenter.router = self
        presenter.interactor = interactor
        presenter.analyticsManager = analyticsManager
        self.presenter = presenter
        let texts = SetCodeViewControllerTexts(
            setCode: SetCodeViewControllerTexts.SetCode(
                title: "manage_card.set_pass_code.title".podLocalized(),
                explanation: "manage_card.set_pass_code.explanation".podLocalized(),
                wrongCodeTitle: "manage_card.confirm_pass_code.error_wrong_code.title".podLocalized(),
                wrongCodeMessage: "manage_card.confirm_pass_code.error_wrong_code.message".podLocalized()
            ),
            confirmCode: SetCodeViewControllerTexts.ConfirmCode(
                title: "manage_card.confirm_pass_code.title".podLocalized(),
                explanation: "manage_card.confirm_pass_code.explanation".podLocalized()
            )
        )
        return serviceLocator.viewLocator.setCodeView(presenter: presenter, texts: texts)
    }

    func codeChanged() {
        finish()
    }
}
