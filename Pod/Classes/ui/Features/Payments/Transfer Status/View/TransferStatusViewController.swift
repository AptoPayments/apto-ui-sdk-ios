import UIKit
import AptoSDK

final class TransferStatusViewController: UIViewController {
  
  private let viewModel: TransferStatusViewModelType
  private let uiConfig: UIConfig
  private lazy var transferStatusView: TransferStatusView = {
      let transferStatusView = TransferStatusView(uiConfig: uiConfig)
      return transferStatusView
  }()
  init(viewModel: TransferStatusViewModelType, uiConfig: UIConfig) {
    self.viewModel = viewModel
    self.uiConfig = uiConfig
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.view = transferStatusView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureNavigationBar()
    self.transferStatusView.use(viewModel: viewModel)
    self.viewModel.input.viewDidLoad()
  }
  
  override func closeTapped() {
    self.viewModel.input.didTapOnClose()
  }
  
  private func configureNavigationBar() {
    showNavCancelButton(.black)
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.isOpaque = true
    navigationController?.navigationBar.barTintColor = .white
  }
}
