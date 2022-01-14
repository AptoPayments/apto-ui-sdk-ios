//
//  UINavigationBar.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 01/08/2018.
//
//

import AptoSDK

extension UINavigationBar {
    func setUpWith(uiConfig: UIConfig) {
        backgroundColor = uiConfig.uiNavigationPrimaryColor
        barTintColor = uiConfig.uiNavigationPrimaryColor
        tintColor = uiConfig.textTopBarPrimaryColor
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: uiConfig.textTopBarPrimaryColor,
        ]
        isTranslucent = false
    }

    func setUp(barTintColor: UIColor, tintColor: UIColor) {
        backgroundColor = barTintColor
        self.barTintColor = barTintColor
        self.tintColor = tintColor
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: tintColor,
        ]
        isTranslucent = false
    }

    func hideShadow() {
        shadowImage = UIImage()
    }

    func showShadow() {
        shadowImage = nil
    }

    func setTransparent() {
        setBackgroundImage(UIImage(), for: .default)
        isTranslucent = true
        hideShadow()
        barTintColor = .clear
        backgroundColor = .clear
    }

    func setOpaque(uiConfig: UIConfig, bgColor: UIColor? = nil, tintColor: UIColor? = nil) {
        setBackgroundImage(nil, for: .default)
        isTranslucent = false
        showShadow()
        barTintColor = tintColor ?? uiConfig.uiPrimaryColor
        backgroundColor = bgColor ?? uiConfig.uiPrimaryColor
    }
}
