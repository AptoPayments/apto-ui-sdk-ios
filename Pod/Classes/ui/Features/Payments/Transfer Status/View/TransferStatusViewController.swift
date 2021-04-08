import UIKit
import AptoSDK

final class TransferStatusViewController: UIViewController {
    
    private let viewModel: TransferStatusViewModelType
    private let uiConfig: UIConfig
    private lazy var transferStatusView: TransferStatusView = {
        let transferStatusView = TransferStatusView(uiConfig: uiConfig)
        return transferStatusView
    }()
    var presentExtraContent: ((_: UIViewController) -> Void)?
    
    init(viewModel: TransferStatusViewModelType, uiConfig: UIConfig) {
        self.viewModel = viewModel
        self.uiConfig = uiConfig
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        self.view = transferStatusView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.transferStatusView.use(viewModel: viewModel)
        self.viewModel.input.viewDidLoad()
        setupBinding()
    }
        
    override func closeTapped() {
        self.viewModel.input.didTapOnClose()
    }
    
    // MARK: Private methods
    private func configureNavigationBar() {
        showNavCancelButton(.black)
        navigationController?.navigationBar.hideShadow()
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.barTintColor = .white
    }
    
    private func setupBinding() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFooterLink))
        transferStatusView.disclaimerLabel.addGestureRecognizer(gesture)
    }
    
    @objc func didTapOnFooterLink() {
        presentExtraContent?(self)
    }
}
