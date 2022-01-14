import AptoSDK
import UIKit

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
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    override func loadView() {
        view = transferStatusView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        transferStatusView.use(viewModel: viewModel)
        viewModel.input.viewDidLoad()
        setupBinding()
    }

    override func closeTapped() {
        viewModel.input.didTapOnClose()
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
