import Foundation
import AptoSDK

protocol AddFundsNavigatorType: AnyObject {
  func navigateToPaymentMethods()
  func navigateToAddCard()
  func navigateToPaymentResult(with result: PaymentResult, and currentPaymentSource: PaymentSource)
}

final class AddFundsNavigator: AddFundsNavigatorType {

  private let from: UIViewController

  init(from: UIViewController) {
    self.from = from
  }
  
  func navigateToAddCard() {
    let viewModel = AddCardViewModel()
    let viewController = AddCardViewController(viewModel: viewModel)
    let navigationController = UINavigationController(
      rootViewController: viewController
    )
    viewModel.navigator = AddCardNavigator(
      from: navigationController
    )
    from.navigationController?.present(navigationController, animated: true)
  }
  
  func navigateToPaymentMethods() {
    let viewModel = PaymentMethodsViewModel()
    let viewController = PaymentMethodsViewController(viewModel: viewModel)
    let navigationController = UINavigationController(
      rootViewController: viewController
    )
    viewModel.navigator = PaymentMethodsNavigator(
      from: navigationController
    )
    from.navigationController?.present(navigationController, animated: true)
  }
  
  func navigateToPaymentResult(with result: PaymentResult, and currentPaymentSource: PaymentSource) {
    let viewModel = TransferStatusViewModel(
      paymentResult: result,
      paymentSource: currentPaymentSource
    )
    let viewController = TransferStatusViewController(viewModel: viewModel)
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
    from.navigationController?.present(navigationController, animated: true)
  }
}
