import AptoSDK
import UIKit

final class PaymentMethodCell: UITableViewCell {
    static let identifier = String(describing: PaymentMethodCell.self)
    private let uiConfig = AptoPlatform.defaultManager().fetchUIConfig()

    private enum ViewLayout {
        static let iconSize = CGSize(width: 42, height: 42)
        static let rightIconSize = CGSize(width: 24, height: 24)
    }

    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
        return label
    }()

    private let rightIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    // MARK: - Configure

    func configure(with item: PaymentMethodItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        icon.image = item.icon
        rightIcon.image = icon(for: item)
        rightIcon.tintColor = uiConfig?.uiPrimaryColor
        backgroundColor = uiConfig?.uiBackgroundPrimaryColor
    }

    private func icon(for item: PaymentMethodItem) -> UIImage? {
        if item.type == .addCard {
            return .imageFromPodBundle("payment_method_arrow")
        }
        return item.isSelected ?
            .imageFromPodBundle("payment_method_selected") :
            .imageFromPodBundle("payment_method_regular")
    }

    // MARK: - Setup View

    private func setupView() {
        accessoryType = .none
        selectionStyle = .none
        addSubview(icon)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        addSubview(stackView)
        addSubview(rightIcon)
    }

    private func setupConstraints() {
        icon.snp.makeConstraints { constraints in
            constraints.top.greaterThanOrEqualToSuperview().offset(12)
            constraints.bottom.greaterThanOrEqualToSuperview().offset(12)
            constraints.size.equalTo(ViewLayout.iconSize)
            constraints.centerY.equalToSuperview()
            constraints.leading.equalToSuperview().offset(16)
        }

        rightIcon.snp.makeConstraints { constraints in
            constraints.size.equalTo(ViewLayout.rightIconSize)
            constraints.centerY.equalToSuperview()
            constraints.trailing.equalToSuperview().inset(16)
        }

        stackView.snp.makeConstraints { constraints in
            constraints.leading.equalTo(icon.snp.trailing).offset(16)
            constraints.centerY.equalToSuperview()
            constraints.trailing.lessThanOrEqualTo(rightIcon.snp.leading).offset(16)
        }
    }
}
