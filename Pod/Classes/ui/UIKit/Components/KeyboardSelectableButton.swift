//
// KeyboardSelectableButton.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/06/2019.
//

import Foundation
import SnapKit

class KeyboardSelectableButton: KeyboardButton {
  init(normalStateConfig: KeyboardStateConfig, selectedStateConfig: KeyboardStateConfig,
       action: ((_ button: KeyboardButton) -> Void)? = nil) {
    super.init(type: .image(normalStateConfig: normalStateConfig), action: action)
    setUpUI(selectedStateConfig: selectedStateConfig)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setUpUI(selectedStateConfig: KeyboardStateConfig) {
    setUpState(selectedStateConfig.image, selectedStateConfig.backgroundColor, .selected)
    clearGestureRecognizers()
    addTapGestureRecognizer { [unowned self] in
      self.action?(self)
      self.isSelected.toggle()
    }
  }
}
