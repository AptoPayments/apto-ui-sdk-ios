//
//  UILabel.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 08/06/16.
//
//

import Foundation

extension UILabel {
    func updateAttributedText(_ text: String?) {
        guard let text = text else {
            self.text = ""
            return
        }
        guard let attributedText = attributedText else {
            self.text = text
            return
        }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.mutableString.setString(text)
        self.attributedText = mutableAttributedString
    }
}
