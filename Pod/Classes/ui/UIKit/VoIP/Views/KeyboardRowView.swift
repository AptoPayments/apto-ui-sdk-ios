//
// KeyboardRowView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/06/2019.
//

import UIKit
import SnapKit

protocol KeyboardRowViewDelegate {
  func leftButtonTapped(sender: KeyboardButton)
  func centerButtonTapped(sender: KeyboardButton)
  func rightButtonTapped(sender: KeyboardButton)
}

class KeyboardRowView: UIView {
  private let leftButton: KeyboardButton
  private let centerButton: KeyboardButton
  private let rightButton: KeyboardButton

  var delegate: KeyboardRowViewDelegate?

  init(leftButton: KeyboardButton, centerButton: KeyboardButton, rightButton: KeyboardButton) {
    self.leftButton = leftButton
    self.centerButton = centerButton
    self.rightButton = rightButton
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    backgroundColor = .clear
    setUpCenterButton()
    setUpLeftButton()
    setUpRightButton()
  }

  private func setUpCenterButton() {
    centerButton.action = { [unowned self] _ in self.delegate?.centerButtonTapped(sender: self.centerButton) }
    addSubview(centerButton)
    centerButton.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }

  private func setUpLeftButton() {
    leftButton.action = { [unowned self] _ in self.delegate?.leftButtonTapped(sender: self.leftButton) }
    addSubview(leftButton)
    leftButton.snp.makeConstraints { make in
      make.top.equalTo(centerButton)
      make.right.equalTo(centerButton.snp.left).offset(-44)
    }
  }

  private func setUpRightButton() {
    rightButton.action = { [unowned self] _ in self.delegate?.rightButtonTapped(sender: self.rightButton) }
    addSubview(rightButton)
    rightButton.snp.makeConstraints { make in
      make.top.equalTo(centerButton)
      make.left.equalTo(centerButton.snp.right).offset(44)
    }
  }
}
