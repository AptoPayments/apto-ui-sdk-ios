//
// CallActionButtonsView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/06/2019.
//

import UIKit
import AptoSDK
import SnapKit

protocol CallActionButtonsViewDelegate: class {
  func speakerButtonTapped(sender: KeyboardButton)
  func muteButtonTapped(sender: KeyboardButton)
  func keypadButtonTapped(sender: KeyboardButton)
}

class CallActionButtonsView: UIView {
  private let uiConfig: UIConfig
  private let speakerButton: KeyboardSelectableButton
  private let muteButton: KeyboardSelectableButton
  private let keypadButton: KeyboardButton

  weak var delegate: CallActionButtonsViewDelegate?

  var isEnabled: Bool = true {
    didSet {
      speakerButton.isEnabled = isEnabled
      muteButton.isEnabled = isEnabled
      keypadButton.isEnabled = isEnabled
    }
  }

  init(uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    self.speakerButton = createSelectableButton(asset: "speaker")
    self.muteButton = createSelectableButton(asset: "mute")
    self.keypadButton = createButton(asset: "dialpad")
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    backgroundColor = .clear
    setUpMuteButton()
    setUpSpeakerButton()
    setUpKeypadButton()
  }

  private func setUpMuteButton() {
    muteButton.action = { [unowned self] _ in self.delegate?.muteButtonTapped(sender: self.muteButton) }
    addSubview(muteButton)
    muteButton.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
    setUpLabel(text: "manage_card.get_pin_voip.mute".podLocalized(), button: muteButton)
  }

  private func setUpSpeakerButton() {
    speakerButton.action = { [unowned self] _ in self.delegate?.speakerButtonTapped(sender: self.speakerButton) }
    addSubview(speakerButton)
    speakerButton.snp.makeConstraints { make in
      make.top.equalTo(muteButton)
      make.right.equalTo(muteButton.snp.left).offset(-44)
    }
    setUpLabel(text: "manage_card.get_pin_voip.speaker".podLocalized(), button: speakerButton)
  }

  private func setUpKeypadButton() {
    keypadButton.action = { [unowned self] _ in self.delegate?.keypadButtonTapped(sender: self.keypadButton) }
    addSubview(keypadButton)
    keypadButton.snp.makeConstraints { make in
      make.top.equalTo(muteButton)
      make.left.equalTo(muteButton.snp.right).offset(44)
    }
    setUpLabel(text: "manage_card.get_pin_voip.keypad".podLocalized(), button: keypadButton)
  }

  private func setUpLabel(text: String, button: KeyboardButton) {
    let label = ComponentCatalog.timestampLabelWith(text: text, uiConfig: uiConfig)
    label.textColor = .white
    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalTo(button.snp.bottom).offset(8)
      make.centerX.equalTo(button)
      make.bottom.equalToSuperview()
    }
  }
}

private let selectedColor = UIColor.white
private let normalColor = selectedColor.withAlphaComponent(0.1)

private func createSelectableButton(asset: String) -> KeyboardSelectableButton {
  let normal = KeyboardStateConfig(image: UIImage.imageFromPodBundle("\(asset)-off"), backgroundColor: normalColor)
  let selected = KeyboardStateConfig(image: UIImage.imageFromPodBundle("\(asset)-on"), backgroundColor: selectedColor)
  return KeyboardSelectableButton(normalStateConfig: normal, selectedStateConfig: selected)
}

private func createButton(asset: String) -> KeyboardButton {
  return KeyboardButton(type: .image(normalStateConfig: KeyboardStateConfig(image: UIImage.imageFromPodBundle(asset),
                                                                            backgroundColor: normalColor)))
}
