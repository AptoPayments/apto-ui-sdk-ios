import AptoSDK
import Bond
import ReactiveKit
import SnapKit
import UIKit

final class AddFundsView: UIView {
    static let maxAllowedDigit = 5
    static let maxAllowedDigitAfterDot = 2

    private lazy var textField: UITextField = {
        let textField = ComponentCatalog.textFieldWith(placeholder: "$0",
                                                       placeholderColor: uiConfig.textSecondaryColor,
                                                       font: .boldSystemFont(ofSize: 44),
                                                       textColor: uiConfig.textPrimaryColor)
        textField.keyboardType = .decimalPad
        textField.textAlignment = .center
        return textField
    }()

    private lazy var currentCardView = CurrentCardView()
    private let keyboardWatcher = KeyboardWatcher()
    private let paymentSourceMapper = PaymentSourceMapper()
    // swiftlint:disable implicitly_unwrapped_optional
    private var nextButton: UIButton!
    // swiftlint:enable implicitly_unwrapped_optional
    private let disposeBag = DisposeBag()
    private var uiConfig: UIConfig

    private(set) lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = uiConfig.fontProvider.formTextLink
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    var didChangeAmountValue: ((String?) -> Void)?
    var didTapOnChangeCurrentCard: (() -> Void)?

    private var viewModel: AddFundsViewModelType?

    init(uiConfig: UIConfig) {
        self.uiConfig = uiConfig
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        watchKeyboard()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemente") }

    // MARK: - Setup View

    private func setupView() {
        backgroundColor = .white
        textField.addSubview(errorLabel)
        addSubview(textField)

        nextButton = .roundedButtonWith("load_funds.add_money.primary_cta".podLocalized(),
                                        backgroundColor: uiConfig.uiPrimaryColor,
                                        cornerRadius: 24) { [weak self] in
            self?.viewModel?.input.didTapOnPullFunds()
        }
        nextButton.isHidden = true

        stackView.addArrangedSubview(currentCardView)
        stackView.addArrangedSubview(nextButton)

        addSubview(stackView)

        textField.becomeFirstResponder()
        textField.delegate = self
    }

    func set(current paymentSource: PaymentSource?) {
        guard let paymentSource = paymentSource else {
            configureDefaultState()
            return
        }

        switch paymentSource {
        case let .card(card):
            configureCardPaymentSource(card: card)
        default:
            break
        }
    }

    func use(viewModel: AddFundsViewModelType) {
        self.viewModel = viewModel
        bind()
    }

    // swiftlint:disable trailing_closure
    private func bind() {
        viewModel?.output.nextButtonEnabled.observeNext(with: { [weak self] nextButtonIsEnabled in
            self?.nextButton.isHidden = !nextButtonIsEnabled
        }).dispose(in: disposeBag)
    }

    private func configureCardPaymentSource(card: CardPaymentSource) {
        let config = CurrentCardConfig(
            title: "•••• \(card.lastFour)",
            subtitle: card.title,
            icon: paymentSourceMapper.icon(from: card.network),
            action: CurrentCardConfig.Action(
                title: "load_funds.add_money.change_card".podLocalized(),
                action: { [weak self] in
                    self?.didTapOnChangeCurrentCard?()
                }
            )
        )
        currentCardView.configure(with: config)
    }

    private func configureDefaultState() {
        let config = CurrentCardConfig(
            title: "load_funds.add_money.no_payment_method".podLocalized(),
            icon: .imageFromPodBundle("credit_debit_card"),
            action: CurrentCardConfig.Action(
                title: "load_funds.add_money.add_card".podLocalized(),
                action: { [weak self] in
                    self?.didTapOnChangeCurrentCard?()
                }
            )
        )
        currentCardView.configure(with: config)
    }

    // swiftlint:enable trailing_closure

    private func watchKeyboard() {
        keyboardWatcher.startWatching { [weak self] size in
            guard let self = self else { return }
            self.textField.snp.updateConstraints { constraints in
                constraints.bottom.equalToSuperview().inset(size.height + 80)
            }
            self.stackView.snp.updateConstraints { constraints in
                constraints.bottom.equalToSuperview().inset(size.height + 16)
            }
        }
    }

    private func setupConstraints() {
        errorLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(38)
        }
        textField.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().inset(16)
            constraints.trailing.equalToSuperview().inset(16)
            constraints.top.equalToSuperview()
            constraints.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().offset(16)
            constraints.trailing.equalToSuperview().inset(16)
            constraints.bottom.equalToSuperview().inset(16)
        }

        nextButton.snp.makeConstraints { constraints in
            constraints.height.equalTo(52)
        }
    }

    // MARK: Public method

    func dailyLimitError(_ limit: String, show: Bool) {
        if show {
            errorLabel.text = "load_funds.add_money.monthly_max.reached".podLocalized().replace(["<<MAX>>": limit])
            UIView.animate(withDuration: 0.3) { [errorLabel] in
                errorLabel.alpha = 1
            }
        } else {
            errorLabel.alpha = 0
        }
    }
}

// MARK: - UITextField

extension AddFundsView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn _: NSRange,
                   replacementString string: String) -> Bool
    {
        dailyLimitError("", show: false)

        let decimalSeparator: String = NSLocale.current.decimalSeparator ?? "."

        guard let text = textField.text else { return false }
        if !shouldAllowDecimalSeparator(lastChar: string, text: text, decimalSeparator: decimalSeparator) {
            return false
        }
        if !string.isEmpty, !Character(string).isNumber, string != decimalSeparator {
            return false
        }

        if text.contains(decimalSeparator) {
            let sides = text.split(separator: Character(decimalSeparator))
            let rightSideCnt = sides.count == 2 ? sides[1].count + 1 : 1
            if rightSideCnt <= AddFundsView.maxAllowedDigitAfterDot {
                didChangeAmountValue?(updateAmountIfNeeded(lastChar: string, text: text + string))
            } else {
                didChangeAmountValue?(updateAmountIfNeeded(lastChar: string, text: text))
            }
        } else {
            if text.count + 1 <= AddFundsView.maxAllowedDigit {
                didChangeAmountValue?(updateAmountIfNeeded(lastChar: string, text: text + string))
            } else {
                didChangeAmountValue?(updateAmountIfNeeded(lastChar: string, text: text))
            }
        }

        if string.isEmpty { return true }
        return shouldAddCharacter(lastChar: string, text: text, decimalSeparator: decimalSeparator)
    }

    private func updateAmountIfNeeded(lastChar: String, text: String) -> String {
        let amount = lastChar.isEmpty ? String(text.dropLast()) : text
        let formatter = NumberFormatter()
        let numericAmount = formatter.number(from: amount)
        if numericAmount?.doubleValue != nil,
           let stringAmount = numericAmount?.stringValue
        {
            return stringAmount
        } else {
            return ""
        }
    }

    private func shouldAllowDecimalSeparator(lastChar: String, text: String, decimalSeparator: String) -> Bool {
        let input = text + lastChar
        let dotCount = input.filter { $0 == Character(decimalSeparator) }.count
        return dotCount <= 1
    }

    private func shouldAddCharacter(lastChar: String, text: String, decimalSeparator: String) -> Bool {
        let input = text + lastChar
        let sides = input.split(separator: Character(decimalSeparator))
        switch sides.count {
        case 1:
            return sides[0].count < AddFundsView.maxAllowedDigit
        case 2:
            return sides[0].count < AddFundsView.maxAllowedDigit &&
                sides[1].count <= AddFundsView.maxAllowedDigitAfterDot
        default:
            return false
        }
    }
}
