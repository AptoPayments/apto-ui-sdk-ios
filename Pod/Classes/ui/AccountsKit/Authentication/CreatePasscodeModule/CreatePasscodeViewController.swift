//
//  CreatePasscodeViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class CreatePasscodeViewController: AptoViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: CreatePasscodePresenterProtocol
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private let pinEntryContainerView = UIView()
  private let pinEntryView: UIPinEntryTextField
  private let detailedExplanationLabel: UILabel
  private var currentCode = ""
  private var isShowingConfirmation = false

  init(uiConfiguration: UIConfig, presenter: CreatePasscodePresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "biometric.create_pin.title".podLocalized(),
                                                           multiline: false, uiConfig: uiConfiguration)
    self.explanationLabel = ComponentCatalog.formLabelWith(text: "biometric.create_pin.description".podLocalized(),
                                                           multiline: true, lineSpacing: uiConfiguration.lineSpacing,
                                                           letterSpacing: uiConfiguration.letterSpacing,
                                                           uiConfig: uiConfiguration)
    let detailedExplanation = "biometric.create_pin.description_long".podLocalized()
    self.detailedExplanationLabel = ComponentCatalog.itemDescriptionLabelWith(text: detailedExplanation,
                                                                              multiline: true,
                                                                              uiConfig: uiConfiguration)
    self.pinEntryView = UIPinEntryTextField(size: 4, frame: CGRect(x: 0, y: 0, width: 168, height: 64),
                                            accessibilityLabel: "Passcode text field")
    super.init(uiConfiguration: uiConfiguration)
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

  private func showEntryPIN() {
    pinEntryView.resetText()
    pinEntryView.focus()
    titleLabel.updateAttributedText("biometric.create_pin.title".podLocalized())
    explanationLabel.updateAttributedText("biometric.create_pin.description".podLocalized())
    detailedExplanationLabel.isHidden = false
    isShowingConfirmation = false
  }

  private func showPINConfirmation() {
    pinEntryView.resetText()
    pinEntryView.focus()
    titleLabel.updateAttributedText("biometric.create_pin.confirmation_title".podLocalized())
    explanationLabel.updateAttributedText("biometric.create_pin.confirmation_title.description".podLocalized())
    detailedExplanationLabel.isHidden = true
    isShowingConfirmation = true
  }
}

private extension CreatePasscodeViewController {
  func setUpViewModelSubscriptions() {
    presenter.viewModel.error.ignoreNils().observeNext { [weak self] error in
      self?.showEntryPIN()
      self?.show(error: error)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension CreatePasscodeViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpPINEntryContainerView()
    setUpPinEntryView()
    setUpDetailedExplanationLabel()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.textTopBarPrimaryColor)
    hideNavPreviousButton()
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

  func setUpDetailedExplanationLabel() {
    view.addSubview(detailedExplanationLabel)
    detailedExplanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(pinEntryContainerView.snp.bottom).offset(36)
    }
  }
}

extension CreatePasscodeViewController: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    let pin = frPinView.getText()
    if !isShowingConfirmation {
      currentCode = pin
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
        self.showPINConfirmation()
      }
    }
    else {
      if currentCode == pin {
        presenter.pinEntered(currentCode)
      }
      else {
        show(message: "biometric.create_pin.error.pin_not_match".podLocalized(),
             title: "biometric.create_pin.error.title".podLocalized(), isError: true)
        showEntryPIN()
        pinEntryView.shake()
      }
    }
  }
}
