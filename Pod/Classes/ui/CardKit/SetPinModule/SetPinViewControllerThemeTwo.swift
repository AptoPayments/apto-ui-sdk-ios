//
// SetPinViewControllerThemeTwo.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class SetPinViewControllerThemeTwo: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: SetPinPresenterProtocol
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private var pinEntryContainerView = UIView()
  private var pinEntryView: UIPinEntryTextField
  private var pin: String?

  init(uiConfiguration: UIConfig, presenter: SetPinPresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "manage_card.set_pin.title".podLocalized(),
                                                           multiline: false, uiConfig: uiConfiguration)
    self.explanationLabel = ComponentCatalog.formLabelWith(text: "manage_card.set_pin.explanation".podLocalized(),
                                                           multiline: true, lineSpacing: uiConfiguration.lineSpacing,
                                                           letterSpacing: uiConfiguration.letterSpacing,
                                                           uiConfig: uiConfiguration)
    self.pinEntryView = UIPinEntryTextField(size: 4, frame: .zero)
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
    if pin != nil {
      updateUIForPin()
    }
    else {
      presenter.closeTapped()
    }
  }
}

extension SetPinViewControllerThemeTwo: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    let newPin = frPinView.getText()
    if let pin = self.pin {
      handlePinConfirmation(pin: pin, newPin: newPin)
    }
    else {
      pin = newPin
      updateUIForPinConfirmation()
    }
  }

  func handlePinConfirmation(pin: String, newPin: String) {
    if pin == newPin {
      presenter.pinEntered(pin)
    }
    else {
      updateUIForPin()
      showPinDoNotMatchErrorMessage()
    }
  }

  func updateUIForPin() {
    view.fadeIn(animations: { [unowned self] in // swiftlint:disable:this trailing_closure
      self.titleLabel.updateAttributedText("manage_card.set_pin.title".podLocalized())
      self.explanationLabel.updateAttributedText("manage_card.set_pin.explanation".podLocalized())
      self.pinEntryView.resetText()
      self.pinEntryView.focus()
      self.navigationItem.leftBarButtonItem = nil
      self.showNavCancelButton()
      self.pin = nil
    })
  }

  func updateUIForPinConfirmation() {
    view.fadeIn(animations: { [unowned self] in // swiftlint:disable:this trailing_closure
      self.titleLabel.updateAttributedText("manage_card.confirm_pin.title".podLocalized())
      self.explanationLabel.updateAttributedText("manage_card.confirm_pin.explanation".podLocalized())
      self.pinEntryView.resetText()
      self.pinEntryView.focus()
      self.navigationItem.leftBarButtonItem = nil
      self.showNavPreviousButton(uiTheme: .theme2)
    })
  }
}

private extension SetPinViewControllerThemeTwo {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.showLoading.ignoreNils().observeNext { [weak self] showLoading in
      self?.handleShowLoading(showLoading)
    }.dispose(in: disposeBag)
    viewModel.error.ignoreNils().observeNext { [weak self] error in
      self?.show(error: error)
    }.dispose(in: disposeBag)
  }

  func handleShowLoading(_ showLoading: Bool) {
    if showLoading {
      showLoadingView()
    }
    else {
      hideLoadingView()
    }
  }
}

// MARK: - Set up UI
private extension SetPinViewControllerThemeTwo {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpTitle()
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpPinEntryContainer()
    setUpPinEntryView()
  }

  func setUpTitle() {
    self.title = ""
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
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
    }
  }

  func setUpPinEntryContainer() {
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
    pinEntryView.pinBorderWidth = 0
    pinEntryView.pinBorderColor = .clear
    pinEntryView.font = uiConfiguration.fontProvider.formFieldFont
    pinEntryView.textColor = uiConfiguration.textSecondaryColor
    pinEntryView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    pinEntryView.tintColor = uiConfiguration.uiPrimaryColor
    pinEntryView.placeholder = "-"
    pinEntryContainerView.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.left.right.equalToSuperview().inset(48)
      make.height.equalTo(44)
    }
    pinEntryView.resetText()
    pinEntryView.focus()
  }

  func showPinDoNotMatchErrorMessage() {
    _ = pinEntryView.resignFirstResponder()
    show(message: "manage_card.confirm_pin.error_wrong_code.message".podLocalized(),
         title: "manage_card.confirm_pin.error_wrong_code.title".podLocalized(), isError: true)
  }
}
