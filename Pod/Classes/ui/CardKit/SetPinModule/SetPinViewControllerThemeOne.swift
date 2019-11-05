//
// SetPinViewControllerThemeOne.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class SetPinViewControllerThemeOne: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: SetPinPresenterProtocol
  private let titleLabel: UILabel
  private var pinEntryView: UIPinEntryTextField
  private var pin: String?

  init(uiConfiguration: UIConfig, presenter: SetPinPresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.formLabelWith(text: "manage_card.set_pin.explanation".podLocalized(),
                                                     textAlignment: .center, multiline: false,
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

extension SetPinViewControllerThemeOne: UIPinEntryTextFieldDelegate {
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
      self.title = "manage_card.set_pin.title".podLocalized()
      self.titleLabel.updateAttributedText("manage_card.set_pin.explanation".podLocalized())
      self.pinEntryView.resetText()
      self.pinEntryView.focus()
      self.navigationItem.leftBarButtonItem = nil
      self.showNavCancelButton()
      self.pin = nil
    })
  }

  func updateUIForPinConfirmation() {
    view.fadeIn(animations: { [unowned self] in // swiftlint:disable:this trailing_closure
      self.title = "manage_card.confirm_pin.title".podLocalized()
      self.titleLabel.updateAttributedText("manage_card.confirm_pin.explanation".podLocalized())
      self.pinEntryView.resetText()
      self.pinEntryView.focus()
      self.navigationItem.leftBarButtonItem = nil
      self.showNavPreviousButton(uiTheme: .theme1)
    })
  }
}

private extension SetPinViewControllerThemeOne {
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
private extension SetPinViewControllerThemeOne {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpTitle()
    setUpNavigationBar()
    setUpTitleLabel()
    setUpPinEntryView()
  }

  func setUpTitle() {
    self.title = "manage_card.set_pin.title".podLocalized()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
  }

  func setUpTitleLabel() {
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(48)
      make.top.equalToSuperview().offset(72)
    }
  }

  func setUpPinEntryView() {
    pinEntryView.delegate = self
    pinEntryView.showMiddleSeparator = false
    view.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(36)
      make.centerX.equalToSuperview()
      make.width.equalTo(186)
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
