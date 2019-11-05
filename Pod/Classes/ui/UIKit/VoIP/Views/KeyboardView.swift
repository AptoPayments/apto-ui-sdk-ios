//
// KeyboardView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/06/2019.
//

import UIKit
import SnapKit

protocol KeyboardViewDelegate: class {
  func didSelectDigit(_ digit: String)
}

class KeyboardView: UIView {
  private let topRowView: KeyboardRowView
  private let middleRowView: KeyboardRowView
  private let bottomRowView: KeyboardRowView
  private let symbolsRowView: KeyboardRowView
  private let rowsSpacing = 28

  weak var delegate: KeyboardViewDelegate?

  init() {
    self.topRowView = KeyboardRowView(leftButton: KeyboardButton(type: .digit(digit: "1")),
                                      centerButton: KeyboardButton(type: .digit(digit: "2")),
                                      rightButton: KeyboardButton(type: .digit(digit: "3")))
    self.middleRowView = KeyboardRowView(leftButton: KeyboardButton(type: .digit(digit: "4")),
                                         centerButton: KeyboardButton(type: .digit(digit: "5")),
                                         rightButton: KeyboardButton(type: .digit(digit: "6")))
    self.bottomRowView = KeyboardRowView(leftButton: KeyboardButton(type: .digit(digit: "7")),
                                         centerButton: KeyboardButton(type: .digit(digit: "8")),
                                         rightButton: KeyboardButton(type: .digit(digit: "9")))
    self.symbolsRowView = KeyboardRowView(leftButton: KeyboardButton(type: .digit(digit: "*")),
                                          centerButton: KeyboardButton(type: .digit(digit: "0")),
                                          rightButton: KeyboardButton(type: .digit(digit: "#")))
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI() {
    backgroundColor = .clear
    setUpTopRowView()
    setUpMiddleRowView()
    setUpBottomRowView()
    setUpSymbolsRowView()
  }

  private func setUpTopRowView() {
    topRowView.delegate = self
    addSubview(topRowView)
    topRowView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
    }
  }

  private func setUpMiddleRowView() {
    middleRowView.delegate = self
    addSubview(middleRowView)
    middleRowView.snp.makeConstraints { make in
      make.top.equalTo(topRowView.snp.bottom).offset(rowsSpacing)
      make.left.right.equalToSuperview()
    }
  }

  private func setUpBottomRowView() {
    bottomRowView.delegate = self
    addSubview(bottomRowView)
    bottomRowView.snp.makeConstraints { make in
      make.top.equalTo(middleRowView.snp.bottom).offset(rowsSpacing)
      make.left.right.equalToSuperview()
    }
  }

  private func setUpSymbolsRowView() {
    symbolsRowView.delegate = self
    addSubview(symbolsRowView)
    symbolsRowView.snp.makeConstraints { make in
      make.top.equalTo(bottomRowView.snp.bottom).offset(rowsSpacing)
      make.left.right.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}

extension KeyboardView: KeyboardRowViewDelegate {
  func leftButtonTapped(sender: KeyboardButton) {
    buttonTapped(button: sender)
  }

  func centerButtonTapped(sender: KeyboardButton) {
    buttonTapped(button: sender)
  }

  func rightButtonTapped(sender: KeyboardButton) {
    buttonTapped(button: sender)
  }

  private func buttonTapped(button: KeyboardButton) {
    delegate?.didSelectDigit(button.title(for: .normal)!) // swiftlint:disable:this force_unwrapping
  }
}
