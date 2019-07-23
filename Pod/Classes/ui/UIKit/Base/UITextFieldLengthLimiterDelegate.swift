//
// UITextFieldLengthLimiterDelegate.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 26/02/2019.
//

import Foundation

class UITextFieldLengthLimiterDelegate: NSObject, UITextFieldDelegate {
  private let maxLength: Int

  init(_ maxLength: Int) {
    self.maxLength = maxLength
    super.init()
  }

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    let currentString: NSString = text as NSString
    let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
  }
}
