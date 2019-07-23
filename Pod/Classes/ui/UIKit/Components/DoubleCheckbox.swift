//
// DoubleCheckbox.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/05/2019.
//

import UIKit
import AptoSDK
import SnapKit

class DoubleCheckbox: UIView {
  private let separation: CGFloat
  let checkbox1: Checkbox
  let checkbox2: Checkbox

  var isEnabled: Bool = true {
    didSet {
      checkbox1.isEnabled = isEnabled
      checkbox2.isEnabled = isEnabled
    }
  }

  init(value1: Bool = false, value2: Bool = false, separation: CGFloat = 44, uiConfig: UIConfig) {
    self.separation = separation
    self.checkbox1 = Checkbox(isChecked: value1, uiConfig: uiConfig)
    self.checkbox2 = Checkbox(isChecked: value2, uiConfig: uiConfig)
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Set up UI
private extension DoubleCheckbox {
  func setUpUI() {
    setUpCheckbox1()
    setUpCheckbox2()
  }

  func setUpCheckbox1() {
    addSubview(checkbox1)
    checkbox1.snp.makeConstraints { make in
      make.left.centerY.equalToSuperview()
      make.width.height.equalTo(18)
    }
  }

  func setUpCheckbox2() {
    addSubview(checkbox2)
    checkbox2.snp.makeConstraints { make in
      make.right.centerY.equalToSuperview()
      make.width.height.equalTo(checkbox1)
      make.left.equalTo(checkbox1.snp.right).offset(separation)
    }
  }
}
