import UIKit
import ReactiveKit
import AptoSDK

final class PaymentMethodsViewController: UIViewController {
  
  private let paymentMethodsView = PaymentMethodsView()
  private let viewModel: PaymentMethodsViewModelType
  private let uiConfig = AptoPlatform.defaultManager().fetchUIConfig()
  private let disposeBag = DisposeBag()
  
  init(viewModel: PaymentMethodsViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.title = "load_funds.payment_methods.title".podLocalized()
    self.view = paymentMethodsView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    self.bind()
  }
  
  private func bind() {
    viewModel.output.state.observeNext { [weak self] state in
      switch state {
      case .idle:
        self?.hideLoadingView()
      case .loading:
        self?.showLoadingView(uiConfig: self?.uiConfig)
      case .loaded(let items):
        self?.hideLoadingView()
        self?.paymentMethodsView.items = items
      case .error(let error):
        self?.hideLoadingView()
        self?.show(error: error, uiConfig: self?.uiConfig)
      }
    }.dispose(in: disposeBag)
    
    viewModel.input.viewDidLoad()
  }
  
  override func closeTapped() {
    viewModel.input.didTapOnClose()
  }
  
  private func configureNavigationBar() {
    showNavCancelButton(.black)
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.isOpaque = true
    navigationController?.navigationBar.barTintColor = .white
  }
}
