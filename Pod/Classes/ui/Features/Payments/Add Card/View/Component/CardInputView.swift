import AptoSDK
import SnapKit
import UIKit

final class CardInputView: UIView {
    private let cardDetector = CardDetector()
    private lazy var cardFormatter: CardFormatter = {
        let cardFormatter = CardFormatter(cardNetworks: cardNetworks)
        return cardFormatter
    }()

    private var numberOfSpaces = 3
    private var maxLength = 16
    private var uiConfig: UIConfig
    private var cardNetworks: [CardNetwork]

    var didChangeFocus: (() -> Void)?
    var didChangeCard: ((_ card: String, _ type: CardType) -> Void)?

    private lazy var cardIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.imageFromPodBundle("credit_debit_card")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var lockIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.imageFromPodBundle("card_lock")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // swiftlint:disable force_unwrapping
    private lazy var borderedView: BorderedView = {
        let borderedView = BorderedView()
        borderedView.set(borderWidth: 1)
        borderedView.set(borderColor: .colorFromHexString("E9EBEE")!)
        borderedView.set(cornerRadius: 8)
        return borderedView
    }()

    // swiftlint:enable force_unwrapping

    private lazy var textField: UITextField = {
        let textField = ComponentCatalog.textFieldWith(placeholderColor: uiConfig.textSecondaryColor,
                                                       font: uiConfig.fontProvider.cardDetailsTextFont,
                                                       textColor: uiConfig.textPrimaryColor)
        textField.keyboardType = .numberPad
        textField.textContentType = .creditCardNumber
        return textField
    }()

    var value: String? {
        get { textField.text }
        set {
            textField.text = newValue
        }
    }

    var placeholder: String? {
        get { textField.placeholder }
        set {
            let attr = [NSAttributedString.Key.foregroundColor: uiConfig.textSecondaryColor]
            textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "",
                                                                 attributes: attr)
        }
    }

    init(uiConfig: UIConfig, cardNetworks: [CardNetwork]) {
        self.cardNetworks = cardNetworks
        self.uiConfig = uiConfig
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not implemented") }

    // MARK: - Setup View

    private func setupView() {
        backgroundColor = .white
        addSubview(borderedView)
        addSubview(cardIcon)
        addSubview(lockIcon)
        addSubview(textField)

        textField.delegate = self
        textField.addTarget(self, action: #selector(didStartEditingTextField), for: .editingDidBegin)
    }

    private func setupConstraints() {
        snp.makeConstraints { constraints in
            constraints.height.equalTo(48)
        }
        cardIcon.snp.makeConstraints { constraints in
            constraints.size.equalTo(CGSize(width: 30, height: 22))
            constraints.leading.equalToSuperview().inset(16)
            constraints.centerY.equalToSuperview()
        }
        borderedView.snp.makeConstraints { constraints in
            constraints.edges.equalToSuperview().inset(2)
        }
        textField.snp.makeConstraints { constraints in
            constraints.leading.equalTo(cardIcon.snp.trailing).offset(16)
            constraints.trailing.equalTo(lockIcon.snp.leading).offset(-16)
            constraints.centerY.equalToSuperview()
        }
        lockIcon.snp.makeConstraints { constraints in
            constraints.size.equalTo(CGSize(width: 16, height: 16))
            constraints.trailing.equalToSuperview().inset(16)
            constraints.centerY.equalToSuperview()
        }
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
}

// MARK: - UITextField

extension CardInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        guard let currentString: String = textField.text,
              let characterRange = Range(range, in: currentString) else { return true }
        let newString = currentString.replacingCharacters(in: characterRange, with: string)
        updateCardIcon(for: newString)
        configureLength(for: newString)
        let cardLengthWithSpaces = maxLength + numberOfSpaces
        let formattedText = cardFormatter.format(String(newString.prefix(cardLengthWithSpaces)))
        self.textField.text = formattedText
        let (cardType, isCardValid) = cardDetector.detect(newString, cardNetworks: cardNetworks)
        if isCardValid, formattedText.count == cardLengthWithSpaces {
            borderedView.hideError()
            didChangeCard?(newString, cardType)
        } else if formattedText.count < cardLengthWithSpaces {
            didChangeCard?("", cardType)
        }
        return false
    }

    @objc private func didStartEditingTextField() {
        if textField.text?.count ?? 0 < maxLength + numberOfSpaces {
            didChangeCard?("", .unknown)
        }
    }

    private func configureLength(for input: String) {
        switch cardDetector.detect(input) {
        case (.amex, _):
            maxLength = 15
            numberOfSpaces = 2
            if input.count == maxLength {
                borderedView.hideError()
            }
        default:
            maxLength = 16
            numberOfSpaces = 3
        }
    }

    private func updateCardIcon(for input: String) {
        switch cardDetector.detect(input, cardNetworks: cardNetworks) {
        case (.amex, _):
            cardIcon.image = .imageFromPodBundle("american_express")
        case (.visa, _):
            cardIcon.image = .imageFromPodBundle("visa")
        case (.discover, _):
            cardIcon.image = .imageFromPodBundle("discover")
        case (.mastercard, _):
            cardIcon.image = .imageFromPodBundle("mastercard")
        default:
            cardIcon.image = .imageFromPodBundle("credit_debit_card")
        }
    }
}
