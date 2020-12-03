import UIKit
import ReactiveKit
import AptoSDK

final class AddCardViewController: UIViewController {
  private var uiConfig: UIConfig
  private let viewModel: AddCardViewModelType
  private let disposeBag = DisposeBag()
  private let cardNetworks: [CardNetwork]
  private lazy var addCardView: AddCardView = {
    let addCardView = AddCardView(uiConfig: uiConfig, cardNetworks: self.cardNetworks)
    return addCardView
  }()
  
  init(viewModel: AddCardViewModelType, uiConfig: UIConfig, cardNetworks: [CardNetwork]) {
    self.viewModel = viewModel
    self.uiConfig = uiConfig
    self.cardNetworks = cardNetworks
    super.init(nibName: nil, bundle: nil)
  }
 
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.title = "load_funds.add_card.title".podLocalized()
    self.view = addCardView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    bind()
  }
  
  private func bind() {
    addCardView.use(viewModel: viewModel)
    viewModel.output.state.observeNext { [weak self] state in
      switch state {
      case .idle:
        self?.hideLoadingView()
      case .loading:
        self?.showLoadingView(uiConfig: nil)
      case .error(let error):
        self?.hideLoadingView()
        self?.show(error: error, uiConfig: nil)
      }
    }.dispose(in: disposeBag)
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
