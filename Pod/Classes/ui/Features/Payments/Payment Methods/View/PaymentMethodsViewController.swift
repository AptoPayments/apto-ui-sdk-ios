import AptoSDK
import ReactiveKit
import UIKit

final class PaymentMethodsViewController: UIViewController {
    private let paymentMethodsView = PaymentMethodsView()
    private let viewModel: PaymentMethodsViewModelType
    private let uiConfig = AptoPlatform.defaultManager().fetchUIConfig()
    private let disposeBag = DisposeBag()

    init(viewModel: PaymentMethodsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    override func loadView() {
        title = "load_funds.payment_methods.title".podLocalized()
        view = paymentMethodsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        bind()
    }

    private func bind() {
        viewModel.output.state.observeNext { [weak self] state in
            switch state {
            case .idle:
                self?.hideLoadingView()
            case .loading:
                self?.showLoadingView(uiConfig: self?.uiConfig)
            case let .loaded(items):
                self?.hideLoadingView()
                self?.paymentMethodsView.items = items
            case let .error(error):
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
