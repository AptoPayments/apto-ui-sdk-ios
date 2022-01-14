//
//  P2PTransferView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 22/7/21.
//

import AptoSDK
import PhoneNumberKit
import SnapKit
import UIKit

public enum InputTextFieldType {
    case phone
    case email
}

class USPhoneNumberTextField: PhoneNumberTextField {
    private var uiConfiguration: UIConfig?
    private var defaultCountry: String?

    convenience init(uiconfig: UIConfig, defaultCountry: String) {
        self.init()
        uiConfiguration = uiconfig
        self.defaultCountry = defaultCountry
    }

    // swiftlint:disable unused_setter_value
    override var defaultRegion: String {
        get {
            guard let defaultCountry = self.defaultCountry else { return "GB" }
            return defaultCountry
        }
        set {}
    }

    // swiftlint:enable unused_setter_value

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += 10
        return textRect
    }
}

public class P2PTransferView: UIView {
    let uiConfiguration: UIConfig
    let defaultCountry: String
    private(set) lazy var headerTextView: UILabel = {
        let label = UILabel()
        label.text = "p2p_transfer.main_screen.title".podLocalized()
        label.font = uiConfiguration.fontProvider.topBarTitleBigFont
        label.textColor = uiConfiguration.textPrimaryColor
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var introLabel: UILabel = {
        let label = UILabel()
        label.font = uiConfiguration.fontProvider.instructionsFont
        label.textColor = uiConfiguration.textSecondaryColor
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "p2p_transfer.main_view.field.email_placeholder".podLocalized(),
            attributes: [NSAttributedString.Key.foregroundColor: uiConfiguration.textTertiaryColor]
        )
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private(set) lazy var phoneTextField: USPhoneNumberTextField = {
        let textField = USPhoneNumberTextField(uiconfig: uiConfiguration, defaultCountry: defaultCountry)
        textField.attributedPlaceholder = NSAttributedString(
            string: "p2p_transfer.main_view.field.phone_number_placeholder".podLocalized(),
            attributes: [NSAttributedString.Key.foregroundColor: uiConfiguration.textTertiaryColor]
        )
        textField.withPrefix = true
        textField.withFlag = true
        return textField
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private(set) lazy var resultsView: P2PRecipientResultView = {
        let resultsView = P2PRecipientResultView(uiconfig: uiConfiguration)
        resultsView.alpha = 0
        return resultsView
    }()

    private(set) lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(uiConfiguration.textButtonColor, for: .normal)
        button.setTitle("application-details.button.continue".podLocalized(), for: .normal)
        button.backgroundColor = uiConfiguration.uiPrimaryColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 24
        button.alpha = 0
        return button
    }()

    private var bottomButtonConstraint: Constraint?

    init(uiconfig: UIConfig, defaultCountry: String) {
        uiConfiguration = uiconfig
        self.defaultCountry = defaultCountry
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
        [
            headerTextView, introLabel,
            emailTextField, phoneTextField,
            activityIndicator, resultsView, continueButton,
        ].forEach(addSubview)
        style(emailTextField)
        style(phoneTextField)
    }

    private func style(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.backgroundColor = uiConfiguration.uiSecondaryColor
        textField.layer.cornerRadius = 16
        textField.layer.shadowOffset = CGSize(width: 0, height: 4)
        textField.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06).cgColor
        textField.layer.shadowOpacity = 1
        textField.layer.shadowRadius = 16
        textField.textColor = uiConfiguration.textPrimaryColor
    }

    private func setupConstraints() {
        headerTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(52)
        }

        introLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(headerTextView.snp.bottom).offset(12)
        }

        emailTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(introLabel.snp.bottom).offset(24)
            make.height.equalTo(56)
        }

        phoneTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(introLabel.snp.bottom).offset(24)
            make.height.equalTo(56)
        }

        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(phoneTextField.snp.bottom).offset(20)
        }

        resultsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(phoneTextField.snp.bottom).offset(20)
            make.height.equalTo(80)
        }

        continueButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            self.bottomButtonConstraint = make.bottom.equalTo(bottomConstraint).inset(34).constraint
            make.height.equalTo(48)
        }
    }

    // MARK: Public methods

    public func configureView(for type: InputTextFieldType, intro: String) {
        introLabel.text = intro.podLocalized()
        switch type {
        case .email:
            phoneTextField.isHidden = true
            phoneTextField.isUserInteractionEnabled = false
        case .phone:
            emailTextField.isHidden = true
            emailTextField.isUserInteractionEnabled = false
        }
    }

    public func set(_ textField: UITextField, invalid: Bool) {
        switch textField {
        case phoneTextField:
            phoneTextField.textColor = invalid ? uiConfiguration.uiErrorColor : uiConfiguration.textTopBarSecondaryColor
        case emailTextField:
            emailTextField.textColor = invalid ? uiConfiguration.uiErrorColor : uiConfiguration.textTopBarSecondaryColor
        default: break
        }
    }

    public func startLoading() {
        activityIndicator.startAnimating()
    }

    public func stopLoading() {
        activityIndicator.stopAnimating()
    }

    public func showResult(with recipient: CardholderData, contact: String) {
        resultsView.configureRecipient(with: recipient, contact: contact)
        UIView.animate(withDuration: 0.3) {
            self.resultsView.alpha = 1
            self.continueButton.alpha = 1
        }
    }

    public func showNoResults(_ description: String) {
        resultsView.showNoResults(with: description)
        UIView.animate(withDuration: 0.3) {
            self.resultsView.alpha = 1
            self.continueButton.alpha = 0
        }
    }

    public func hideResultsView() {
        resultsView.alpha = 0
        continueButton.alpha = 0
    }

    public func updateButtonPosition(to position: CGFloat) {
        bottomButtonConstraint?.update(inset: position)
    }
}
