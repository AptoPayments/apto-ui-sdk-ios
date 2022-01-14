import AptoSDK
import Foundation

final class PaymentMethodsNavigator: PaymentMethodsNavigatorType {
    private var uiConfig: UIConfig
    private let from: UIViewController
    private let cardNetworks: [CardNetwork]

    init(from: UIViewController, uiConfig: UIConfig, cardNetworks: [CardNetwork]) {
        self.from = from
        self.uiConfig = uiConfig
        self.cardNetworks = cardNetworks
    }

    func didTapOnAddCard() {
        let viewModel = AddCardViewModel(cardNetworks: cardNetworks)
        let viewController = AddCardViewController(viewModel: viewModel, uiConfig: uiConfig, cardNetworks: cardNetworks)
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        viewModel.navigator = AddCardNavigator(
            from: navigationController
        )
        from.present(navigationController, animated: true)
    }

    func close() {
        from.dismiss(animated: true)
    }
}
