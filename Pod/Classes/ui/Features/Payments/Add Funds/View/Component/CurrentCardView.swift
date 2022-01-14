import AptoSDK
import SnapKit
import UIKit

final class CurrentCardView: UIView {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private var currentCardConfig: CurrentCardConfig?
    private let uiConfig = AptoPlatform.defaultManager().fetchUIConfig()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    // MARK: - Setup View

    private func setupView() {
        backgroundColor = .white
        addSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        addSubview(stackView)
        addSubview(actionButton)

        actionButton.addTarget(self, action: #selector(didTapOnActionButton), for: .touchUpInside)
    }

    private func setupConstraints() {
        snp.makeConstraints { constraints in
            constraints.height.equalTo(56)
        }

        iconImageView.snp.makeConstraints { constraints in
            constraints.centerY.equalToSuperview()
            constraints.leading.equalToSuperview().offset(16)
            constraints.size.equalTo(CGSize(width: 40, height: 40))
        }

        stackView.snp.makeConstraints { constraints in
            constraints.leading.equalTo(iconImageView.snp.trailing).offset(8)
            constraints.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
            constraints.centerY.equalToSuperview()
        }

        actionButton.snp.makeConstraints { constraints in
            constraints.centerY.equalToSuperview()
            constraints.trailing.equalToSuperview().inset(16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureShadow()
    }

    // MARK: - Configure shadow

    private func configureShadow() {
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.cornerRadius = 16
    }

    // MARK: - Configure

    func configure(with config: CurrentCardConfig) {
        currentCardConfig = config

        iconImageView.image = config.icon
        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle

        let font: UIFont = config.subtitle == nil ?
            .systemFont(ofSize: 14, weight: .semibold) :
            .systemFont(ofSize: 13, weight: .semibold)
        let color: UIColor = config.subtitle == nil ? .gray : .black

        titleLabel.font = font
        titleLabel.textColor = color

        let attributedTitle = NSAttributedString(
            string: config.action.title,
            attributes: [
                .foregroundColor: uiConfig?.uiPrimaryColor ?? .blue,
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            ]
        )
        actionButton.setAttributedTitle(attributedTitle, for: .normal)
    }

    // MARK: - Button action

    @objc private func didTapOnActionButton() {
        currentCardConfig?.action.action()
    }
}
