//
// VoIPViewController.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/06/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit
import AVFoundation

class VoIPViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: VoIPPresenterProtocol
  private let titleLabel: UILabel
  private let messageLabel: UILabel
  private let hangupButtonConfig = KeyboardStateConfig(image: UIImage.imageFromPodBundle("call-finish"),
                                                       backgroundColor: UIColor.colorFromHex(0xFE3B30))
  private let hangupButton: KeyboardButton
  private let actionsView: CallActionButtonsView
  private let keyboardView = KeyboardView()
  private let hideKeyboardButton = UIButton(type: .custom)
  private let audioSession = AVAudioSession.sharedInstance()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  init(uiConfiguration: UIConfig, presenter: VoIPPresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.topBarTitleLabelWith(text: "manage_card.get_pin_voip.title".podLocalized(),
                                                            uiConfig: uiConfiguration)
    let message = "manage_card.get_pin_voip.message".podLocalized()
    self.messageLabel = ComponentCatalog.mainItemRegularLabelWith(text: message, textAlignment: .center,
                                                                  uiConfig: uiConfiguration)
    self.actionsView = CallActionButtonsView(uiConfig: uiConfiguration)
    self.hangupButton = KeyboardButton(type: .image(normalStateConfig: hangupButtonConfig))
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
}

private extension VoIPViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    combineLatest(viewModel.callState.ignoreNils(),
                  viewModel.timeElapsed).observeNext { [weak self] callState, timeElapsed in
      self?.updateViewForCallState(callState, timeElapsed: timeElapsed)
    }.dispose(in: disposeBag)
    viewModel.error.ignoreNils().observeNext { [weak self] error in
      self?.show(error: error)
    }.dispose(in: disposeBag)
  }

  private func updateViewForCallState(_ state: CallState, timeElapsed: String?) {
    actionsView.isEnabled = state == .established
    switch state {
    case .starting:
      messageLabel.updateAttributedText("manage_card.get_pin_voip.message".podLocalized())
    case .established:
      messageLabel.updateAttributedText(timeElapsed ?? " ")
    case .finished:
      break
    }
  }
}

// MARK: - Set up UI
private extension VoIPViewController {
  func setUpUI() {
    view.backgroundColor = UIColor.colorFromHex(0x222222)
    setUpTitle()
    setUpNavigationBar()
    setUpTitleLabel()
    setUpMessageLabel()
    setUpHangupButton()
    setUpActionView()
    setUpKeyboardView()
    setUpHideKeyboardButton()
  }

  func setUpTitle() {
    self.title = ""
  }

  func setUpNavigationBar() {
    navigationController?.isNavigationBarHidden = true
  }

  func setUpTitleLabel() {
    titleLabel.textColor = .white
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(136)
      make.left.right.equalToSuperview().inset(40)
    }
  }

  func setUpMessageLabel() {
    messageLabel.textColor = .white
    view.addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.left.right.equalTo(titleLabel)
    }
  }

  func setUpHangupButton() {
    view.addSubview(hangupButton)
    hangupButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().inset(88)
    }
    hangupButton.action = { [weak self] _ in self?.presenter.hangupCallTapped() }
  }

  func setUpActionView() {
    actionsView.isEnabled = false
    actionsView.delegate = self
    view.addSubview(actionsView)
    actionsView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(hangupButton.snp.top).offset(-44)
    }
  }

  func setUpKeyboardView() {
    keyboardView.delegate = self
    keyboardView.isHidden = true
    view.addSubview(keyboardView)
    keyboardView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(actionsView.snp.bottom)
    }
  }

  func setUpHideKeyboardButton() {
    hideKeyboardButton.isHidden = true
    hideKeyboardButton.titleLabel?.font = uiConfiguration.fontProvider.timestampFont
    hideKeyboardButton.setTitleColor(.white, for: .normal)
    hideKeyboardButton.setTitle("manage_card.get_pin_voip.hide".podLocalized(), for: .normal)
    hideKeyboardButton.addTapGestureRecognizer { [unowned self] in self.toggleKeyboard() }
    view.addSubview(hideKeyboardButton)
    hideKeyboardButton.snp.makeConstraints { make in
      make.centerY.equalTo(hangupButton)
      make.left.equalTo(hangupButton.snp.right).offset(56)
    }
  }

  func toggleKeyboard() {
    view.animate(animations: { [unowned self] in
      self.actionsView.isHidden.toggle()
      self.hideKeyboardButton.isHidden.toggle()
      self.keyboardView.isHidden.toggle()
    })
  }
}

extension VoIPViewController: CallActionButtonsViewDelegate {
  func speakerButtonTapped(sender: KeyboardButton) {
    let speaker: AVAudioSession.PortOverride = sender.isSelected ? .none : .speaker
    do {
      try audioSession.overrideOutputAudioPort(speaker)
    }
    catch {}
  }

  func muteButtonTapped(sender: KeyboardButton) {
    if sender.isSelected {
      presenter.unmuteCallTapped()
    }
    else {
      presenter.muteCallTapped()
    }
  }

  func keypadButtonTapped(sender: KeyboardButton) {
    toggleKeyboard()
  }
}

extension VoIPViewController: KeyboardViewDelegate {
  func didSelectDigit(_ digit: String) {
    presenter.keyboardDigitTapped(digit)
  }
}
