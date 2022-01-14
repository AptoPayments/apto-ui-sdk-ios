//
//  UIButton.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/02/16.
//
//

import Bond
import UIKit

extension UIButton {
    static func roundedButtonWith(_ title: String,
                                  backgroundColor: UIColor,
                                  accessibilityLabel: String? = nil,
                                  cornerRadius: CGFloat = 5,
                                  tapHandler: @escaping () -> Void) -> UIButton
    {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: UIControl.State())
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        button.accessibilityLabel = accessibilityLabel
        _ = button.reactive.tap.observeNext(with: tapHandler)
        return button
    }

    func updateAttributedTitle(_ title: String?, for state: UIControl.State) {
        guard let attributedTitle = attributedTitle(for: state), let newTitle = title else {
            setTitle(title, for: state)
            return
        }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedTitle)
        mutableAttributedString.mutableString.setString(newTitle)
        setAttributedTitle(mutableAttributedString, for: state)
    }
}
