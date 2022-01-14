import AptoSDK
import UIKit

final class TransferStatusCell: UITableViewCell {
    static let identifier = String(describing: TransferStatusCell.self)

    private enum ViewLayout {
        static let iconSize = CGSize(width: 24, height: 24)
    }

    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    private let subtitleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
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

    func configure(with item: TransferStatusItem, uiConfig: UIConfig?) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        icon.image = item.icon
        selectionStyle = .none
        backgroundColor = uiConfig?.uiBackgroundPrimaryColor
        titleLabel.textColor = uiConfig?.textPrimaryColor
        subtitleLabel.textColor = uiConfig?.textPrimaryColor
    }

    // MARK: - Setup View

    private func setupView() {
        subtitleStackView.addArrangedSubview(icon)
        subtitleStackView.addArrangedSubview(subtitleLabel)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(subtitleStackView)
        addSubview(stackView)
        addSubview(separatorView)
    }

    private func setupConstraints() {
        stackView.snp.makeConstraints { constraints in
            constraints.edges.equalToSuperview().inset(17)
        }
        separatorView.snp.makeConstraints { constraints in
            constraints.bottom.equalToSuperview().inset(4)
            constraints.height.equalTo(1)
            constraints.leading.equalTo(15)
            constraints.trailing.equalToSuperview()
        }
    }
}
