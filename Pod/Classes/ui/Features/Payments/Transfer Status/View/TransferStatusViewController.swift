import UIKit

final class TransferStatusViewController: UIViewController {
  private let transferStatusView = TransferStatusView()
  private let viewModel: TransferStatusViewModelType
  
  init(viewModel: TransferStatusViewModelType) {
    self.viewModel = viewModel
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
