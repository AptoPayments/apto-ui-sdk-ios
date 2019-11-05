//
//  PINVerificationViewControllerTheme1.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class PINVerificationViewControllerTheme1: PINVerificationViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PINVerificationPresenter
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var datapointValueLabel: UILabel!
  private var pinEntryView: UIPinEntryTextField!
  private var expiredPinLabel: UILabel!
  private var resendExplanationLabel: UILabel!
  private var resendCountDownLabel: UILabel!
  private var resendButton: UIButton!
  // swiftlint:enable implicitly_unwrapped_optional

  init(uiConfig: UIConfig, presenter: PINVerificationPresenter) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfig)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setupViewModelSubscriptions()
    presenter.viewLoaded()
  }

  private func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.datapointValue.observeNext { phoneNumber in
      self.datapointValueLabel.text = phoneNumber
    }.dispose(in: disposeBag)
    viewModel.title.observeNext { title in
      self.title = title
    }.dispose(in: disposeBag)
    viewModel.subtitle.observeNext { subtitle in
      self.titleLabel.text = subtitle
    }.dispose(in: disposeBag)
    viewModel.footerTitle.observeNext { footerTitle in
      self.resendExplanationLabel.updateAttributedText(footerTitle)
    }.dispose(in: disposeBag)
    viewModel.resendButtonState.ignoreNils().observeNext { state in
      self.set(resendButtonState: state)
    }.dispose(in: disposeBag)
    viewModel.pinEntryState.ignoreNils().observeNext { state in
      self.set(pinEntryState: state)
    }.dispose(in: disposeBag)
  }

  private func set(resendButtonTitle: String) {
    resendButton.updateAttributedTitle(resendButtonTitle, for: .normal)
  }

  private func set(resendButtonState: ResendButtonState) {
    resendExplanationLabel.isHidden = false
    switch resendButtonState {
    case .enabled:
      resendButton.isHidden = false
      resendCountDownLabel.isHidden = true
    case .waiting(let pendingSeconds):
      let waitTimeDescription = TimeInterval(pendingSeconds).stringFromTimeInterval()
      let newText = "auth.verify_phone.resent_wait_text".podLocalized().replace(["<<WAIT_TIME>>": waitTimeDescription])
      resendCountDownLabel.text = newText
      resendButton.isHidden = true
      resendCountDownLabel.isHidden = false
    }
  }

  private func set(pinEntryState: PINEntryState) {
    switch pinEntryState {
    case .enabled:
      expiredPinLabel.isHidden = true
      pinEntryView.isHidden = false
    case .expired:
      expiredPinLabel.isHidden = false
      pinEntryView.isHidden = true
      pinEntryView.resetText()
    }
  }

  @objc func viewTapped() {
    _ = pinEntryView.resignFirstResponder()
  }

  func showWrongPinError(error: Error, title: String) {
    show(message: error.localizedDescription, title: title, isError: true, uiConfig: uiConfiguration, tapHandler: nil)
    pinEntryView.resetText()
  }

  func showPinResent() {
    _ = pinEntryView.resignFirstResponder()
    show(message: "auth.verify_phone.resent.message".podLocalized(),
         title: "auth.verify_phone.resent.title".podLocalized(),
         animated: true,
         tapHandler: nil)
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

extension PINVerificationViewControllerTheme1: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    _ = frPinView.resignFirstResponder()
    presenter.submitTapped(frPinView.getText())
  }

  func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField) {
  }
}

private extension PINVerificationViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    edgesForExtendedLayout = UIRectEdge()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(PINVerificationViewControllerTheme1.viewTapped)))
    setUpNavigationBar()
    setUpTitleLabel()
    setUpPhoneNumberLabel()
    setUpPinEntryView()
    setUpExpiredPinLabel()
    setUpResendButton()
    setUpResendCountDownLabel()
    setUpResendExplanationLabel()
  }

  private func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
  }

  private func setUpTitleLabel() {
    titleLabel = ComponentCatalog.formLabelWith(text: "",
                                                textAlignment: .center,
                                                multiline: true,
                                                uiConfig: uiConfiguration)
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(48)
      make.top.equalTo(view).offset(72)
    }
  }

  private func setUpPhoneNumberLabel() {
    datapointValueLabel = ComponentCatalog.mainItemRegularLabelWith(text: "",
                                                                 textAlignment: .center,
                                                                 multiline: true,
                                                                 uiConfig: uiConfiguration)
    datapointValueLabel.font = uiConfiguration.fontProvider.formFieldFont
    datapointValueLabel.textColor = uiConfiguration.textSecondaryColor
    view.addSubview(datapointValueLabel)
    datapointValueLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.left.right.equalTo(view).inset(48)
    }
  }

  private func setUpPinEntryView() {
    pinEntryView = UIPinEntryTextField(size: 6,
                                       frame: CGRect(x: 0, y: 0, width: 252, height: 64),
                                       accessibilityLabel: "PIN Field")
    pinEntryView.delegate = self
    view.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.top.equalTo(datapointValueLabel.snp.bottom).offset(52)
      make.centerX.equalTo(view)
      make.left.right.equalToSuperview().inset(48)
      make.height.equalTo(44)
    }
    pinEntryView.resetText()
    pinEntryView.focus()
  }

  func setUpExpiredPinLabel() {
    expiredPinLabel = ComponentCatalog.instructionsLabelWith(text: "auth.verify_phone.expired_pin.text".podLocalized(),
                                                             textAlignment: .center,
                                                             uiConfig: uiConfiguration)
    expiredPinLabel.textColor = uiConfiguration.uiErrorColor
    expiredPinLabel.isHidden = true
    view.addSubview(expiredPinLabel)
    expiredPinLabel.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(pinEntryView)
    }
  }

  private func setUpResendButton() {
    resendButton = ComponentCatalog.formTextLinkButtonWith(
      title: "auth.verify_phone.resend_button.title".podLocalized(),
      uiConfig: uiConfiguration) { [weak self] in
        self?.presenter.resendTapped()
    }
    resendButton.isHidden = true
    view.addSubview(resendButton)
    resendButton.snp.makeConstraints { make in
      make.top.equalTo(pinEntryView.snp.bottom).offset(130)
      make.left.right.equalTo(view).inset(60)
    }
  }

  func setUpResendExplanationLabel() {
    resendExplanationLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                                    textAlignment: .center,
                                                                    uiConfig: uiConfiguration)
    resendExplanationLabel.isHidden = true
    view.addSubview(resendExplanationLabel)
    resendExplanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(60)
      make.bottom.equalTo(resendCountDownLabel.snp.top)
    }
  }

  func setUpResendCountDownLabel() {
    resendCountDownLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                                  textAlignment: .center,
                                                                  uiConfig: uiConfiguration)
    resendCountDownLabel.isHidden = true
    view.addSubview(resendCountDownLabel)
    resendCountDownLabel.snp.makeConstraints { make in
      make.left.right.equalTo(view).inset(60)
      make.bottom.equalTo(resendButton.snp.top).offset(-30)
    }
  }
}
