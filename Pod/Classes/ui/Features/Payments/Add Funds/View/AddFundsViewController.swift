import AptoSDK
import ReactiveKit
import UIKit

final class AddFundsViewController: UIViewController {
    private var viewModel: AddFundsViewModelType
    private var uiConfig: UIConfig
    private let disposeBag = DisposeBag()
    private lazy var addFundsView: AddFundsView = {
        let addFundsView = AddFundsView(uiConfig: uiConfig)
        return addFundsView
    }()

    var onPaymentSourceLoaded: (() -> Void)?

    init(viewModel: AddFundsViewModelType, uiConfig: UIConfig) {
        self.viewModel = viewModel
        self.uiConfig = uiConfig
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    override func loadView() {
        title = "load_funds.add_money.title".podLocalized()
        view = addFundsView
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
            case let .alert(alert):
                self?.present(alert, animated: true)
            case .loading:
                self?.showLoadingView(uiConfig: self?.uiConfig)
            case let .loaded(paymentSource):
                if paymentSource == nil {
                    self?.onPaymentSourceLoaded?()
                }
                self?.addFundsView.set(current: paymentSource)
            case let .error(error):
                self?.show(error: error, uiConfig: self?.uiConfig)
            }
        }.dispose(in: disposeBag)

        addFundsView.didTapOnChangeCurrentCard = { [weak self] in
            self?.showAddCardScreen()
        }

        addFundsView.didChangeAmountValue = { [weak self] value in
            self?.viewModel.input.didChangeAmount(value: value)
        }

        addFundsView.use(viewModel: viewModel)

        viewModel.exceedsDailyLimitsAmount = { [addFundsView] limit in
            addFundsView.dailyLimitError(String(limit), show: true)
        }
    }

    func showAddCardScreen() {
        viewModel.input.didTapOnChangeCard()
    }
}
