import AptoSDK
import ReactiveKit
import UIKit

final class PassCodeOnboardingViewController: UIViewController {
    private let viewModel: PassCodeOnboardingViewModelType
    private var uiConfig: UIConfig
    private let disposeBag = DisposeBag()
    private lazy var passCodeOnboardingView: PassCodeOnboardingView = {
        let view = PassCodeOnboardingView(uiConfig: uiConfig)
        return view
    }()

    init(viewModel: PassCodeOnboardingViewModelType, uiConfig: UIConfig) {
        self.viewModel = viewModel
        self.uiConfig = uiConfig
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    override func loadView() {
        view = passCodeOnboardingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        bind()
    }

    override func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.setUp(barTintColor: uiConfig.uiNavigationSecondaryColor,
                                                  tintColor: uiConfig.iconTertiaryColor)
        navigationController?.navigationBar.hideShadow()
        navigationItem.leftBarButtonItem?.tintColor = uiConfig.iconTertiaryColor
        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = true
        setNeedsStatusBarAppearanceUpdate()
        showNavCancelButton()
    }

    private func bind() {
        passCodeOnboardingView.didTapOnCancel = { [weak self] in
            self?.closeTapped()
        }
        viewModel.output.state.observeNext { [weak self] state in
            switch state {
            case .idle:
                self?.hideLoadingView()
            case .loading:
                self?.showLoadingView(uiConfig: self?.uiConfig)
            case .loaded:
                self?.hideLoadingView()
            case let .error(error):
                self?.hideLoadingView()
                self?.show(error: error, uiConfig: self?.uiConfig)
            }
        }.dispose(in: disposeBag)
        passCodeOnboardingView.use(viewModel: viewModel)
    }
}
