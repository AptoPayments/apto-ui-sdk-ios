import UIKit
import ReactiveKit
import AptoSDK

final class AddFundsViewController: UIViewController {
  private let addFundsView = AddFundsView()
  private let viewModel: AddFundsViewModelType
  private let uiConfig = AptoPlatform.defaultManager().fetchUIConfig()
  private let disposeBag = DisposeBag()
  
  init(viewModel: AddFundsViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.title = "load_funds.add_money.title".podLocalized()
    self.view = addFundsView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    bind()
    viewModel.input.viewDidLoad()
  }
  
  private func configureNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.isOpaque = true
  }
  
  private func bind() {
    viewModel.output.state.observeNext { [weak self] state in
      self?.hideLoadingView()
      
      switch state {
      case .idle:
        break
      case .alert(let alert):
        self?.present(alert, animated: true)
      case .loading:
        self?.showLoadingView(uiConfig: self?.uiConfig)
      case .loaded(let paymentSource):
        self?.addFundsView.set(current: paymentSource)
      case .error(let error):
        self?.show(error: error, uiConfig: self?.uiConfig)
      }
    }.dispose(in: disposeBag)
    
    addFundsView.set(uiConfig: self.uiConfig)
    addFundsView.didTapOnChangeCurrentCard = { [weak self] in
      self?.viewModel.input.didTapOnChangeCard()
    }
    
    addFundsView.didChangeAmountValue = { [weak self] value in
      self?.viewModel.input.didChangeAmount(value: value)
    }
    
    self.addFundsView.use(viewModel: viewModel)
  }
}
