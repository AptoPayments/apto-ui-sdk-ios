//
// KeyboardButton.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/06/2019.
//

import Foundation

struct KeyboardStateConfig {
  let image: UIImage?
  let backgroundColor: UIColor
}

enum KeyboardButtonType {
  case image(normalStateConfig: KeyboardStateConfig)
  case digit(digit: Character)
}

class KeyboardButton: UIButton {
  private let type: KeyboardButtonType
  var action: ((_ button: KeyboardButton) -> Void)?

  init(type: KeyboardButtonType, action: ((_ button: KeyboardButton) -> Void)? = nil) {
    self.type = type
    self.action = action
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    setUpSelf()
    switch type {
    case .image(let normalStateConfig):
      setUpState(normalStateConfig.image, normalStateConfig.backgroundColor, .normal)
    case .digit(let digit):
      setBackgroundImage(UIImage(color: UIColor.white.withAlphaComponent(0.10)), for: .highlighted)
      setTitle(String(digit), for: .normal)
      titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }
  }

  private func setUpSelf() {
    snp.makeConstraints { make in
      make.width.height.equalTo(56)
    }
    layer.cornerRadius = 28
    layer.masksToBounds = true
    addTapGestureRecognizer { [unowned self] in
      self.action?(self)
    }
  }

  func setUpState(_ image: UIImage?, _ color: UIColor, _ state: UIControl.State) {
    setBackgroundImage(UIImage(color: color), for: state)
    setImage(image, for: state)
  }
}
