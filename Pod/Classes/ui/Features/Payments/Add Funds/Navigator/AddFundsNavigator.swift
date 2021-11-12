import Foundation
import AptoSDK

protocol AddFundsNavigatorType: AnyObject {
  func navigateToPaymentMethods(defaultSelectedPaymentMethod: PaymentSource?)
  func navigateToAddCard()
  func navigateToPaymentResult(with result: PaymentResult, and currentPaymentSource: PaymentSource)
}

final class AddFundsNavigator: AddFundsNavigatorType {
  private var uiConfig: UIConfig
  private let from: UIViewController
  private let softDescriptor: String
  private let cardNetworks: [CardNetwork]

    var presentExtraContent: ((_: UIViewController) -> Void)?
    
  init(from: UIViewController, uiConfig: UIConfig, softDescriptor: String, cardNetworks: [CardNetwork]) {
    self.cardNetworks = cardNetworks
    self.from = from
    self.uiConfig = uiConfig
    self.softDescriptor = softDescriptor
  }
  
  func navigateToAddCard() {
    let viewModel = AddCardViewModel(cardNetworks: cardNetworks)
    let viewController = AddCardViewController(viewModel: viewModel, uiConfig: uiConfig, cardNetworks: cardNetworks)
    let navigationController = UINavigationController(
      rootViewController: viewController
    )
    viewModel.navigator = AddCardNavigator(
      from: navigationController
    )
    from.navigationController?.present(navigationController, animated: true)
  }
  
    func navigateToPaymentMethods(defaultSelectedPaymentMethod: PaymentSource? = nil) {
        let viewModel = PaymentMethodsViewModel()
        if let defaultSelectedItem = defaultSelectedPaymentMethod {
          viewModel.selectedPaymentMethod = PaymentSourceMapper().map(defaultSelectedItem, action: nil, deleteAction: nil)
        }
        
        let viewController = PaymentMethodsViewController(viewModel: viewModel)
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        viewModel.navigator = PaymentMethodsNavigator(
            from: navigationController,
            uiConfig: uiConfig,
            cardNetworks: cardNetworks
        )
        from.navigationController?.present(navigationController, animated: true)
    }
  
  func navigateToPaymentResult(with result: PaymentResult, and currentPaymentSource: PaymentSource) {
    let viewModel = TransferStatusViewModel(
      paymentResult: result,
      paymentSource: currentPaymentSource,
      softDescriptor: softDescriptor
    )
    let viewController = TransferStatusViewController(viewModel: viewModel, uiConfig: uiConfig)
    viewController.presentExtraContent = { [weak self] presenter in
        self?.presentExtraContent?(presenter)
    }
    
    let navigationController = UINavigationController(
      rootViewController: viewController
    )
    let transferStatusNavigator = TransferStatusNavigator(
      from: navigationController
    )
    transferStatusNavigator.onFinish = { [weak self] in
      self?.from.navigationController?.popViewController(animated: true)
    }
    viewModel.navigator = transferStatusNavigator
    navigationController.modalPresentationStyle = .fullScreen
    from.navigationController?.present(navigationController, animated: true)
  }
}
