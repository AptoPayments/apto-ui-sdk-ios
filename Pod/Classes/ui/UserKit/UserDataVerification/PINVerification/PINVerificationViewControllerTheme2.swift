//
// PINVerificationViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/11/2018.
//

import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class PINVerificationViewControllerTheme2: PINVerificationViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PINVerificationPresenter
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var explanationLabel: UILabel!
  private var pinEntryContainerView: UIView!
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
    viewModel.title.ignoreNils().observeNext { [unowned self] title in
      self.titleLabel.updateAttributedText(title)
    }.dispose(in: disposeBag)
    viewModel.subtitle.ignoreNils().observeNext { [unowned self] subtitle in
      self.explanationLabel.updateAttributedText(subtitle)
    }.dispose(in: disposeBag)
    viewModel.footerTitle.ignoreNils().observeNext { footerTitle in
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
      pinEntryContainerView.isHidden = false
    case .expired:
      expiredPinLabel.isHidden = false
      pinEntryContainerView.isHidden = true
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

extension PINVerificationViewControllerTheme2: UIPinEntryTextFieldDelegate {
  func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
    _ = frPinView.resignFirstResponder()
    presenter.submitTapped(frPinView.getText())
  }

  func pinEntryTextField(didDeletePin frPinView: UIPinEntryTextField) {
  }
}

private extension PINVerificationViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    edgesForExtendedLayout = UIRectEdge()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(PINVerificationViewControllerTheme2.viewTapped)))
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpPinEntryView()
    setUpExpiredPinLabel()
    setUpResendExplanationLabel()
    setUpResendButton()
    setUpResendCountDownLabel()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.textTopBarPrimaryColor)
  }

  func setUpTitleLabel() {
    titleLabel = ComponentCatalog.largeTitleLabelWith(text: "", multiline: false, uiConfig: uiConfiguration)
    titleLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpExplanationLabel() {
    explanationLabel = ComponentCatalog.formLabelWith(text: " ",
                                                      multiline: true,
                                                      lineSpacing: uiConfiguration.lineSpacing,
                                                      letterSpacing: uiConfiguration.letterSpacing,
                                                      uiConfig: uiConfiguration)
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
    }
  }

  func setUpPinEntryView() {
    let container = createPINEntryContainer()
    pinEntryContainerView = container
    pinEntryView = UIPinEntryTextField(size: 6,
                                       frame: CGRect(x: 0, y: 0, width: 252, height: 64),
                                       accessibilityLabel: "PIN Field")
    pinEntryView.delegate = self
    pinEntryView.showMiddleSeparator = false
    pinEntryView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    pinEntryView.tintColor = uiConfiguration.uiPrimaryColor
    pinEntryView.pinBorderWidth = 0
    pinEntryView.pinBorderColor = .clear
    pinEntryView.font = uiConfiguration.fontProvider.formFieldFont
    pinEntryView.textColor = uiConfiguration.textSecondaryColor
    pinEntryView.placeholder = "-"
    container.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.left.right.equalToSuperview().inset(48)
      make.height.equalTo(44)
    }
    pinEntryView.resetText()
    pinEntryView.focus()
  }

  func setUpExpiredPinLabel() {
    expiredPinLabel = ComponentCatalog.instructionsLabelWith(text: "auth.verify_phone.expired_pin.text".podLocalized(),
                                                             textAlignment: .left,
                                                             uiConfig: uiConfiguration)
    expiredPinLabel.textColor = uiConfiguration.uiErrorColor
    expiredPinLabel.isHidden = true
    view.addSubview(expiredPinLabel)
    expiredPinLabel.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(pinEntryContainerView)
    }
  }

  func createPINEntryContainer() -> UIView {
    let containerView = UIView()
    containerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    containerView.layer.cornerRadius = uiConfiguration.fieldCornerRadius
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
    containerView.layer.shadowOpacity = 1
    containerView.layer.shadowRadius = 4
    view.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.equalTo(explanationLabel.snp.bottom).offset(48)
      make.left.right.equalTo(titleLabel)
      make.height.equalTo(uiConfiguration.formRowHeight)
    }

    return containerView
  }

  func setUpResendExplanationLabel() {
    resendExplanationLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                                    textAlignment: .left,
                                                                    uiConfig: uiConfiguration)
    resendExplanationLabel.isHidden = true
    view.addSubview(resendExplanationLabel)
    resendExplanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(pinEntryView.snp.bottom).offset(resendTopDistance)
    }
  }

  func setUpResendCountDownLabel() {
    resendCountDownLabel = ComponentCatalog.instructionsLabelWith(text: "",
                                                                  textAlignment: .left,
                                                                  uiConfig: uiConfiguration)
    resendCountDownLabel.isHidden = true
    view.addSubview(resendCountDownLabel)
    resendCountDownLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(resendExplanationLabel.snp.bottom)
    }
  }

  func setUpResendButton() {
    let title = "auth.verify_phone.resend_button.title".podLocalized()
    resendButton = ComponentCatalog.formTextLinkButtonWith(title: title, uiConfig: uiConfiguration) { [weak self] in
      self?.pinEntryView.resetText()
      self?.presenter.resendTapped()
      self?.pinEntryView.focus()
    }
    resendButton.isHidden = true
    view.addSubview(resendButton)
    resendButton.snp.removeConstraints()
    resendButton.snp.makeConstraints { make in
      make.top.equalTo(resendExplanationLabel.snp.bottom)
      make.left.equalTo(titleLabel)
    }
  }

  var resendTopDistance: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 48
    default:
      return 68
    }
  }
}
