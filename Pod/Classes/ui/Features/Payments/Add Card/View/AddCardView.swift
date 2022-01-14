import AptoSDK
import Bond
import ReactiveKit
import SnapKit
import UIKit

final class AddCardView: UIView {
    private let expirationDateValidator = ExpirationDateValidator()
    private let keyboardWatcher = KeyboardWatcher()
    private var viewModel: AddCardViewModelType?
    private let disposeBag = DisposeBag()
    private var uiConfig: UIConfig
    private var cardNetworks: [CardNetwork]
    private lazy var cardInputView: CardInputView = {
        let cardInput = CardInputView(uiConfig: uiConfig, cardNetworks: self.cardNetworks)
        cardInput.placeholder = "load_funds.add_card.card_number.placeholder".podLocalized()
        return cardInput
    }()

    private lazy var expirationDateInputView: TextInputView = {
        let pattern = ExpirationDateValidator()
        let textInput = TextInputView(uiConfig: uiConfig)
        textInput.maximumLength = 5
        textInput.validator = { input in
            pattern.validate(input ?? "")
        }
        textInput.formatter = { updatedText, string in
            if string == "" {
                if updatedText.count == 2 {
                    textInput.value = "\(updatedText.prefix(1))"
                    return false
                }
            } else if updatedText.count == 1 {
                if updatedText > "1" {
                    return true
                }
            } else if updatedText.count == 2 {
                textInput.value = "\(updatedText)/"
                return false
            } else if updatedText.count > 5 {
                return false
            }
            return true
        }
        textInput.keyboardType = .numberPad
        textInput.placeholder = "load_funds.add_card.date.placeholder".podLocalized()
        return textInput
    }()

    private lazy var cvvCodeInputView: TextInputView = {
        let textInput = TextInputView(uiConfig: uiConfig)
        textInput.maximumLength = 3
        textInput.validator = { input in
            input?.count ?? 0 == textInput.maximumLength
        }
        textInput.formatter = { updatedText, _ in
            updatedText.count <= textInput.maximumLength
        }
        textInput.keyboardType = .numberPad
        textInput.placeholder = "load_funds.add_card.cvv.placeholder".podLocalized()
        return textInput
    }()

    static let zipCodeMaxLength = 5

    private lazy var zipCodeInputView: TextInputView = {
        let pattern = ZipCodeValidator(failReasonMessage: "Wrong Zip Code")
        let textInput = TextInputView(uiConfig: uiConfig)
        textInput.maximumLength = AddCardView.zipCodeMaxLength
        textInput.validator = { input in
            pattern.validate(input) == .pass
        }
        textInput.formatter = { updatedText, string in
            if string == "" {
                if updatedText.count == AddCardView.zipCodeMaxLength {
                    textInput.value = "\(updatedText.prefix(AddCardView.zipCodeMaxLength))"
                    return false
                }
            } else if updatedText.count > AddCardView.zipCodeMaxLength {
                return false
            }
            return true
        }
        textInput.keyboardType = .numberPad
        textInput.placeholder = "load_funds.add_card.zip.placeholder".podLocalized()
        return textInput
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private let secondaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()

    // swiftlint:disable implicitly_unwrapped_optional
    private var addCardButton: UIButton!
    // swiftlint:enable implicitly_unwrapped_optional

    init(uiConfig: UIConfig, cardNetworks: [CardNetwork]) {
        self.uiConfig = uiConfig
        self.cardNetworks = cardNetworks
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        configureValidators()
        watchKeyboard()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    // MARK: - Setup View

    private func setupView() {
        backgroundColor = .white
        addCardButton = .roundedButtonWith("load_funds.add_card.primary_cta".podLocalized(),
                                           backgroundColor: .blue,
                                           cornerRadius: 24) { [weak self] in
            self?.endEditing(true)
            self?.viewModel?.input.didTapOnAddCard()
        }

        secondaryStackView.addArrangedSubview(expirationDateInputView)
        secondaryStackView.addArrangedSubview(cvvCodeInputView)

        mainStackView.addArrangedSubview(cardInputView)
        mainStackView.addArrangedSubview(secondaryStackView)
        mainStackView.addArrangedSubview(zipCodeInputView)

        addSubview(mainStackView)
        addSubview(addCardButton)

        cardInputView.becomeFirstResponder()
    }

    func use(viewModel: AddCardViewModelType) {
        self.viewModel = viewModel
        bind()
    }

    private func hideCardDetails(card: String) {
        if card.isEmpty {
            cvvCodeInputView.isHidden = true
            zipCodeInputView.isHidden = true
            expirationDateInputView.isHidden = true
        } else {
            cvvCodeInputView.isHidden = false
            zipCodeInputView.isHidden = false
            expirationDateInputView.isHidden = false
            cvvCodeInputView.value = ""
            zipCodeInputView.value = ""
            expirationDateInputView.value = ""
            viewModel?.input.didChange(expiration: "")
            viewModel?.input.didChange(zipCode: "")
            viewModel?.input.didChange(cvv: "")
        }
    }

    private func bind() {
        cardInputView.didChangeCard = { [weak self] card, type in
            self?.hideCardDetails(card: card)
            switch type {
            case .amex:
                self?.cvvCodeInputView.maximumLength = 4
            default:
                self?.cvvCodeInputView.maximumLength = 3
            }

            self?.viewModel?.input.didChange(card: card, with: type)
        }

        expirationDateInputView.didChangeValue = { [weak self] expirationDate in
            guard let expirationDate = expirationDate else { return }
            self?.viewModel?.input.didChange(expiration: expirationDate)
        }

        cvvCodeInputView.didChangeValue = { [weak self] cvv in
            guard let cvv = cvv else { return }
            self?.viewModel?.input.didChange(cvv: cvv)
        }

        zipCodeInputView.didChangeValue = { [weak self] zipCode in
            guard let zipCode = zipCode else { return }
            self?.viewModel?.input.didChange(zipCode: zipCode)
        }

        viewModel?.output.addCardButtonEnabled.observeNext { [weak self] isEnabled in
            self?.addCardButton.isHidden = !isEnabled
        }.dispose(in: disposeBag)
    }

    private func watchKeyboard() {
        // swiftlint:disable trailing_closure
        keyboardWatcher.startWatching(onKeyboardShown: { [weak self] size in
            guard let self = self else { return }
            self.addCardButton.snp.updateConstraints { constraints in
                constraints.bottom.equalToSuperview().inset(size.height + 16)
            }
        })
        // swiftlint:enable trailing_closure
    }

    private func configureValidators() {
        expirationDateInputView.validator = { [expirationDateValidator] input in
            guard let input = input, !input.isEmpty else { return true }
            return expirationDateValidator.validate(input)
        }
    }

    private func setupConstraints() {
        mainStackView.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().inset(16)
            constraints.trailing.equalToSuperview().inset(16)

            if #available(iOS 11.0, *) {
                constraints.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            } else {
                constraints.top.equalToSuperview().offset(16)
            }
        }

        addCardButton.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().inset(16)
            constraints.trailing.equalToSuperview().inset(16)
            constraints.height.equalTo(52)
            constraints.bottom.equalToSuperview().inset(16)
        }
    }
}
