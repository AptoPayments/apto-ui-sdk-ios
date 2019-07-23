//
// SectionHeaderViewTheme1.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 15/01/2019.
//

import UIKit
import AptoSDK
import SnapKit

class SectionHeaderViewTheme1: UIView {
  private let uiConfig: UIConfig

  init(text: String, uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    super.init(frame: .zero)
    setupUI(text: text)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI(text: String) {
    backgroundColor = uiConfig.uiBackgroundPrimaryColor
    setUpLabel(text: text)
  }

  private func setUpLabel(text: String) {
    let label = UILabel()
    label.textColor = uiConfig.textSecondaryColor
    label.font = uiConfig.fontProvider.sectionTitleFont
    label.text = text
    addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(4)
    }
  }
}
