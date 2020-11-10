import Foundation

final class PaymentMethodsNavigator: PaymentMethodsNavigatorType {
  
  private let from: UIViewController
  
  init(from: UIViewController) {
    self.from = from
  }
  
  func didTapOnAddCard() {
    let viewModel = AddCardViewModel()
    let viewController = AddCardViewController(viewModel: viewModel)
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
