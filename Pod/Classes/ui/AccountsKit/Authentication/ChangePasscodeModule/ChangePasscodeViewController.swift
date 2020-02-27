//
//  ChangePasscodeViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 13/02/2020.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class ChangePasscodeViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: ChangePasscodePresenterProtocol
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private let pinEntryContainerView = UIView()
  private let pinEntryView: UIPinEntryTextField
  private var forgotPasscodeButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfiguration: UIConfig, presenter: ChangePasscodePresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: " ", multiline: true, uiConfig: uiConfiguration)
    self.explanationLabel = ComponentCatalog.formLabelWith(text: " ", multiline: true,
                                                           lineSpacing: uiConfiguration.lineSpacing,
                                                           letterSpacing: uiConfiguration.letterSpacing,
                                                           uiConfig: uiConfiguration)
    self.pinEntryView = UIPinEntryTextField(size: 4, frame: CGRect(x: 0, y: 0, width: 168, height: 64),
                                            accessibilityLabel: "Passcode text field")
    super.init(uiConfiguration: uiConfiguration)
    let forgotPasscodeTitle = "biometric.verify_pin.forgot.cta".podLocalized()
    self.forgotPasscodeButton = ComponentCatalog.formTextLinkButtonWith(title: forgotPasscodeTitle,
                                                                        uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.forgotPasscodeTapped()
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

private extension ChangePasscodeViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.step.observeNext { [unowned self] step in
      switch step {
      case .verifyPasscode:
        self.setUpForPasscodeVerification()
      case .setPasscode:
        self.setUpForSetPasscode()
      case .confirmPasscode:
        self.setUpForConfirmPasscode()
      }
    }.dispose(in: disposeBag)
    viewModel.error.ignoreNils().observeNext { [unowned self] error in
      _ = self.pinEntryView.resignFirstResponder()
      self.show(error: error)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
        self.pinEntryView.resetText()
      }
    }.dispose(in: disposeBag)
  }

  func setUpForPasscodeVerification() {
    titleLabel.updateAttributedText("biometric.verify_pin.title".podLocalized())
    explanationLabel.updateAttributedText("biometric.verify_pin.explanation".podLocalized())
    pinEntryView.resetText()
    pinEntryView.focus()
    forgotPasscodeButton.isHidden = false
  }

  func setUpForSetPasscode() {
    titleLabel.updateAttributedText("biometric.change_pin.enter_passcode.title".podLocalized())
    explanationLabel.updateAttributedText("biometric.change_pin.enter_passcode.explanation".podLocalized())
    pinEntryView.resetText()
    pinEntryView.focus()
    forgotPasscodeButton.isHidden = true
  }

  func setUpForConfirmPasscode() {
    titleLabel.updateAttributedText("biometric.change_pin.confirm_passcode.title".podLocalized())
    explanationLabel.updateAttributedText("biometric.change_pin.confirm_passcode.explanation".podLocalized())
    pinEntryView.resetText()
    pinEntryView.focus()
    forgotPasscodeButton.isHidden = true
  }
}

// MARK: - Set up UI
private extension ChangePasscodeViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpPINEntryContainerView()
    setUpPinEntryView()
    setUpForgotPasscodeButton()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.textTopBarPrimaryColor)
  }

  func setUpTitleLabel() {
    titleLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpExplanationLabel() {
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
    }
  }

  func setUpPINEntryContainerView() {
    pinEntryContainerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    pinEntryContainerView.layer.cornerRadius = uiConfiguration.fieldCornerRadius
    pinEntryContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    pinEntryContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
    pinEntryContainerView.layer.shadowOpacity = 1
    pinEntryContainerView.layer.shadowRadius = 4
    view.addSubview(pinEntryContainerView)
    pinEntryContainerView.snp.makeConstraints { make in
      make.top.equalTo(explanationLabel.snp.bottom).offset(48)
      make.left.right.equalTo(titleLabel)
      make.height.equalTo(uiConfiguration.formRowHeight)
    }
  }

  func setUpPinEntryView() {
    pinEntryView.delegate = self
    pinEntryView.showMiddleSeparator = false
    pinEntryView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    pinEntryView.tintColor = uiConfiguration.uiPrimaryColor
    pinEntryView.pinBorderWidth = 0
    pinEntryView.pinBorderColor = .clear
    pinEntryView.font = uiConfiguration.fontProvider.formFieldFont
    pinEntryView.textColor = uiConfiguration.textSecondaryColor
    pinEntryView.placeholder = "-"
    pinEntryView.isSecureTextEntry = true
    pinEntryContainerView.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.left.right.equalToSuperview().inset(64)
      make.height.equalTo(44)
    }
    pinEntryView.resetText()
    pinEntryView.focus()
  }

  func setUpForgotPasscodeButton() {
    view.addSubview(forgotPasscodeButton)
    forgotPasscodeButton.snp.makeConstraints { make in
      make.left.equalTo(titleLabel)
      make.top.equalTo(pinEntryContainerView.snp.bottom).offset(36)
    }
  }
}

extension ChangePasscodeViewController: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    let passcode = frPinView.getText()
    presenter.passcodeEntered(passcode)
  }
}
