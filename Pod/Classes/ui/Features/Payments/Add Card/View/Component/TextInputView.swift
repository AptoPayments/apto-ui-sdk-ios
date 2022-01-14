import AptoSDK
import SnapKit
import UIKit

final class TextInputView: UIView {
    private var uiConfig: UIConfig
    private let MAXIMUM_DEFAULT_LENGTH = 3
    private let MINIMUM_DEFAULT_LENGTH = 0
    private var maxLength: Int?
    private var minLength: Int?
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
        let textField = ComponentCatalog.textFieldWith(font: uiConfig.fontProvider.cardDetailsTextFont,
                                                       textColor: uiConfig.textPrimaryColor)
        textField.autocorrectionType = .no
        return textField
    }()

    var validator: ((String?) -> Bool)?
    var formatter: ((String, String) -> Bool)?
    var didChangeValue: ((String?) -> Void)?

    var value: String? {
        get { textField.text }
        set { textField.text = newValue
            borderedView.hideError()
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

    var maximumLength: Int {
        get { maxLength ?? MAXIMUM_DEFAULT_LENGTH }
        set { maxLength = newValue }
    }

    var minimumLength: Int {
        get { minLength ?? MINIMUM_DEFAULT_LENGTH }
        set { minLength = newValue }
    }

    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }

    init(uiConfig: UIConfig) {
        self.uiConfig = uiConfig
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("Not Implemented") }

    // MARK: - Setup View

    private func setupView() {
        backgroundColor = .white
        addSubview(borderedView)
        addSubview(textField)

        textField.delegate = self
    }

    private func setupConstraints() {
        snp.makeConstraints { constraints in
            constraints.height.equalTo(48)
        }
        borderedView.snp.makeConstraints { constraints in
            constraints.edges.equalToSuperview().inset(2)
        }
        textField.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().offset(16)
            constraints.trailing.equalToSuperview().offset(-16)
            constraints.centerY.equalToSuperview()
        }
    }
}

// MARK: - UITextFieldDelegate

extension TextInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentString: String = textField.text,
              let characterRange = Range(range, in: currentString) else { return true }
        let newString = currentString.replacingCharacters(in: characterRange, with: string)
        
        if string.isEmpty &&
            currentString.count != 3 &&
            Array(currentString)[range.location] == "/" {
            return false
        }
        
        if validator?(String(newString.prefix(maxLength ?? MAXIMUM_DEFAULT_LENGTH))) ?? true {
            borderedView.hideError()
            didChangeValue?(String(newString.prefix(maxLength ?? MAXIMUM_DEFAULT_LENGTH)))
        } else {
            didChangeValue?("")
        }

        return formatter?(newString, string) ?? (newString.count <= maxLength ?? MAXIMUM_DEFAULT_LENGTH)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let inputIsValidated = validator?(textField.text) ?? true
        var lengthIsCorrect = true
        if (textField.text?.count ?? 0) <= maxLength ?? MAXIMUM_DEFAULT_LENGTH &&
            (textField.text?.count ?? 0) >= minLength ?? MINIMUM_DEFAULT_LENGTH {
            lengthIsCorrect = true
        } else {
            lengthIsCorrect = false
        }

        if !inputIsValidated || !lengthIsCorrect {
            borderedView.showError()
        } else {
            borderedView.hideError()
        }
    }
}
