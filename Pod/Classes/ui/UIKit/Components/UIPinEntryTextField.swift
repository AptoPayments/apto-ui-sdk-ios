//
//  UIPinEntryTextField.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/07/2017.
//
//

import AptoSDK
import SnapKit
import UIKit

private protocol _UITextFieldDelegate: AnyObject {
    func deletePressed(_ textField: _UITextField)
    func shouldBecomeFirstResponder(_ textField: _UITextField) -> Bool
    func selectFirstResponder()
}

private class _UITextField: UITextField {
    weak var _delegate: _UITextFieldDelegate? // swiftlint:disable:this identifier_name

    override func deleteBackward() {
        _delegate?.deletePressed(self)
        super.deleteBackward()
    }

    func forceBecomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }

    override func becomeFirstResponder() -> Bool {
        switch _delegate?.shouldBecomeFirstResponder(self) {
        case .none, .some(true):
            return forceBecomeFirstResponder()
        case .some(false):
            _delegate?.selectFirstResponder()
            return false
        }
    }
}

@objc protocol UIPinEntryTextFieldDelegate {
    func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField)
    @objc optional func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField)
}

class UIPinEntryTextField: UIView {
    // Variables
    private let stackView = UIStackView()
    private var textFields = [_UITextField]()
    private var keyboardType: UIKeyboardType = .numberPad
    private var pinViewWidth: Int {
        return (pinWidth * pinCount) + (pinSpacing * pinCount)
    }

    private let middleSeparatorView = UIView()
    private var separatorView: UIView {
        return middleSeparatorView.subviews[0]
    }

    private var notificationHandler: NotificationHandler {
        return ServiceLocator.shared.notificationHandler
    }

    weak var delegate: UIPinEntryTextFieldDelegate?

    // Outlets
    var pinCount: Int = 6
    var pinSpacing: Int = 4
    var pinWidth: Int = 32
    var pinHeight: Int = 44
    var pinCornerRadius: CGFloat = 5
    var pinBorderWidth: CGFloat = 1
    override var backgroundColor: UIColor? {
        didSet {
            textFields.forEach { $0.backgroundColor = self.backgroundColor }
        }
    }

    var textColor: UIColor = .black {
        didSet {
            textFields.forEach { $0.textColor = textColor }
        }
    }

    override var tintColor: UIColor? {
        didSet {
            textFields.forEach { $0.tintColor = self.tintColor }
        }
    }

    var font = UIFont.systemFont(ofSize: 17) {
        didSet {
            textFields.forEach { $0.font = font }
        }
    }

    var pinBorderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.00) {
        didSet {
            textFields.forEach { $0.layer.borderColor = pinBorderColor.cgColor }
            separatorView.backgroundColor = pinBorderColor
        }
    }

    var showMiddleSeparator: Bool = true {
        didSet {
            middleSeparatorView.isHidden = !showMiddleSeparator
        }
    }

    var middleSeparatorWidth: CGFloat = 12 {
        didSet {
            separatorView.snp.updateConstraints { make in
                make.width.equalTo(middleSeparatorWidth)
            }
        }
    }

    var middleSeparatorHeight: CGFloat = 2 {
        didSet {
            separatorView.snp.updateConstraints { make in
                make.width.equalTo(middleSeparatorHeight)
            }
        }
    }

    var placeholder: String? {
        didSet {
            textFields.forEach { $0.placeholder = placeholder }
        }
    }

    var isSecureTextEntry: Bool = false {
        didSet {
            textFields.forEach { $0.isSecureTextEntry = isSecureTextEntry }
        }
    }

    init(size: Int, frame: CGRect, accessibilityLabel: String? = nil) {
        super.init(frame: frame)

        // Styling textfield
        pinCount = size

        if let accessibilityLabel = accessibilityLabel {
            self.accessibilityLabel = accessibilityLabel
            isAccessibilityElement = true
        }

        createTextFields()
        createMiddleSeparator()
        setUpStackView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createTextFields()
        createMiddleSeparator()
        setUpStackView()
    }

    deinit {
        notificationHandler.removeObserver(self)
    }

    /// Generate textfield
    private func createTextFields() {
        // Create textfield based on size
        for index in 0 ..< pinCount {
            let textField = _UITextField()

            // Set textfield params
            textField.keyboardType = keyboardType
            textField.textAlignment = .center
            textField.backgroundColor = backgroundColor
            textField.tintColor = backgroundColor
            textField.textColor = textColor
            textField.delegate = self
            textField.isSecureTextEntry = isSecureTextEntry
            textField._delegate = self
            if let accessibilityLabel = accessibilityLabel {
                textField.accessibilityLabel = accessibilityLabel + " (" + String(index + 1) + ")"
            }

            // Styling textfield
            textField.layer.cornerRadius = pinCornerRadius
            textField.layer.borderWidth = pinBorderWidth
            textField.layer.borderColor = pinBorderColor.cgColor

            notificationHandler.addObserver(self, selector: #selector(fieldChanged),
                                            name: UITextField.textDidChangeNotification, object: textField)

            textFields.append(textField)
        }
    }

    private func createMiddleSeparator() {
        middleSeparatorView.backgroundColor = .clear
        middleSeparatorView.isHidden = !showMiddleSeparator
        addSubview(middleSeparatorView)

        let separatorView = UIView()
        separatorView.backgroundColor = pinBorderColor
        middleSeparatorView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(middleSeparatorWidth)
            make.height.equalTo(middleSeparatorHeight)
        }
    }

    /// Make textfield rounded
    private func setUpStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        textFields.forEach {
            stackView.addArrangedSubview($0)
        }
        let middleIndex = textFields.count / 2
        stackView.insertArrangedSubview(middleSeparatorView, at: middleIndex)
        let shouldShowSeparator = showMiddleSeparator && (textFields.count % 2 == 0)
        middleSeparatorView.isHidden = !shouldShowSeparator
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let visibleSubviews = middleSeparatorView.isHidden ? textFields.count : textFields.count + 1
        stackView.spacing = (bounds.size.width - CGFloat(visibleSubviews * pinWidth)) / CGFloat(visibleSubviews - 1)
    }

    /// Move forward to textfield
    ///
    /// - Parameter textField: textField Current textfield
    private func moveFrom(currentTextField textField: _UITextField) {
        guard let index = textFields.firstIndex(of: textField), index < (pinCount - 1) else { return }
        if let current = currentTextField, current != textField { return }
        currentTextField = textFields[index + 1]
        textFields[index + 1].text = ""
        _ = textFields[index + 1].forceBecomeFirstResponder()
    }

    /// Move backward from textfield
    ///
    /// - Parameter textField: textField Current textfield
    private func moveBackwardFrom(currentTextField textField: _UITextField) {
        guard let index = textFields.firstIndex(of: textField), index > 0 else { return }
        if let current = currentTextField, current != textField { return }
        currentTextField = textFields[index - 1]
        textFields[index].text = ""
        textFields[index - 1].text = ""
        _ = textFields[index - 1].forceBecomeFirstResponder()
    }

    /// Get text from all pin textfields
    ///
    /// - Returns: return String Text from all pin textfields
    func getText() -> String {
        return textFields.compactMap { $0.text }.reduce("") { $0 + $1 } // swiftlint:disable:this trailing_closure
    }

    /// Reset text values
    func resetText() {
        currentTextField = nil
        textFields.forEach { $0.text = "" }
    }

    /// Make the first textfield become first responder
    func focus() {
        _ = textFields[0].forceBecomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        for textField in textFields {
            textField.resignFirstResponder()
        }
        return true
    }

    @objc private func fieldChanged(_ notification: Notification) {
        if let sender = notification.object as? UITextField {
            if sender == textFields.last, getText().count == pinCount {
                let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.delegate?.pinEntryTextField(didFinishInput: self)
                }
            }
        }
    }

    private var currentTextField: _UITextField?
}

extension UIPinEntryTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn _: NSRange,
                   replacementString string: String) -> Bool
    {
        guard let textField = textField as? _UITextField else { return true }
        let char = string.cString(using: String.Encoding.utf8)! // swiftlint:disable:this force_unwrapping
        let isBackSpace = strcmp(char, "\\b")

        if isBackSpace == -92 {
            if let string = textField.text {
                if string.isEmpty {
                    // last visible character, if needed u can skip replacement and detect once even in empty text field
                    // for example u can switch to prev textField
                    let delayTime = DispatchTime.now() + Double(Int64(0.001 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.moveBackwardFrom(currentTextField: textField)
                    }
                }
            }
        } else {
            if textField == textFields.last, textField.text != "" {
                return false
            }
            // If there is already a value then forward the new text to the next textfield. This is needed to make the SMS
            // autocomplete work.
            if textField.text != "" {
                let current = currentTextField ?? textField
                moveFrom(currentTextField: current)
                currentTextField?.insertText(string)
                return false
            } else {
                let delayTime = DispatchTime.now() + Double(Int64(0.001 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.moveFrom(currentTextField: textField)
                }
            }
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField as? _UITextField
    }
}

extension UIPinEntryTextField: _UITextFieldDelegate {
    fileprivate func deletePressed(_ textField: _UITextField) {
        if textField.text?.isEmpty == true {
            moveBackwardFrom(currentTextField: textField)
        }
    }

    fileprivate func shouldBecomeFirstResponder(_ textField: _UITextField) -> Bool {
        return (textField.text?.count ?? 0 > 0) || (textField === textFields[getText().count])
    }

    fileprivate func selectFirstResponder() {
        _ = textFields[getText().count].forceBecomeFirstResponder()
    }
}
