import UIKit
import ReactiveKit
import AptoSDK

final class AddFundsViewController: UIViewController {
  private var viewModel: AddFundsViewModelType
  private var uiConfig: UIConfig
  private let disposeBag = DisposeBag()
  private lazy var addFundsView: AddFundsView = {
      let addFundsView = AddFundsView(uiConfig: uiConfig)
      return addFundsView
  }()
    
  init(viewModel: AddFundsViewModelType, uiConfig: UIConfig) {
    self.viewModel = viewModel
    self.uiConfig = uiConfig
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
    
    addFundsView.didTapOnChangeCurrentCard = { [weak self] in
      self?.viewModel.input.didTapOnChangeCard()
    }
    
    addFundsView.didChangeAmountValue = { [weak self] value in
      self?.viewModel.input.didChangeAmount(value: value)
    }
    
    self.addFundsView.use(viewModel: viewModel)
    
    viewModel.exceedsDailyLimitsAmount = { [addFundsView] limit in
        addFundsView.dailyLimitError(String(limit), show: true)
    }
  }
}
