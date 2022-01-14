import AptoSDK
import Bond
import ReactiveKit
import SnapKit
import UIKit

final class PassCodeOnboardingView: UIView {
    private var uiConfig: UIConfig
    private lazy var titleLabel: UILabel = {
        ComponentCatalog.largeTitleLabelWith(text: "manage_card.set_passcode.start.title".podLocalized(),
                                             uiConfig: uiConfig)
    }()

    private lazy var descriptionLabel: UILabel = {
        ComponentCatalog.formLabelWith(text: "manage_card.set_passcode.start.description".podLocalized(),
                                       multiline: true,
                                       uiConfig: uiConfig)
    }()

    private lazy var nextButton: UIButton = {
        ComponentCatalog.buttonWith(title: "manage_card.set_passcode.start.primary_cta".podLocalized(),
                                    uiConfig: uiConfig) { self.viewModel?.input.didTapOnSetPassCode() }
    }()

    private lazy var cancelButton: UIButton = {
        ComponentCatalog.secondaryButtonWith(title: "manage_card.set_passcode.start.secondary_cta".podLocalized(),
                                             uiConfig: uiConfig) { self.didTapOnCancel?() }
    }()

    var didTapOnCancel: (() -> Void)?

    private var viewModel: PassCodeOnboardingViewModelType?

    init(uiConfig: UIConfig) {
        self.uiConfig = uiConfig
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    func use(viewModel: PassCodeOnboardingViewModelType) {
        self.viewModel = viewModel
    }

    // MARK: - Setup View

    private func setupView() {
        backgroundColor = uiConfig.uiBackgroundSecondaryColor
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(nextButton)
        addSubview(cancelButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().offset(24)
            constraints.trailing.equalToSuperview().inset(24)
            constraints.top.equalToSuperview().inset(24)
        }
        descriptionLabel.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().offset(24)
            constraints.trailing.equalToSuperview().inset(24)
            constraints.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        cancelButton.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().offset(24)
            constraints.trailing.equalToSuperview().inset(24)
            constraints.bottom.equalToSuperview().inset(36)
        }
        nextButton.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().offset(24)
            constraints.trailing.equalToSuperview().inset(24)
            constraints.bottom.equalTo(cancelButton.snp.top).offset(-24)
        }
    }
}
