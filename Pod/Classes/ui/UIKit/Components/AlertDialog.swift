//
//  AlertDialog.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 8/7/21.
//

import AptoSDK

public final class AlertDialog {
    public static func showToast(to viewController: UIViewController, error: Error, uiConfig: UIConfig?) {
        let backgroundColor = uiConfig?.uiErrorColor ?? UIColor.colorFromHex(0xDC4337)
        let font = uiConfig?.fontProvider.mainItemRegularFont
        let textColor = uiConfig?.textMessageColor
        let toast = Toast(text: error.localizedDescription, textAlignment: .left, backgroundColor: backgroundColor,
                          textColor: textColor, font: font, duration: 5, minimumHeight: 100, style: .bottomToTop)
        viewController.present(toast, animated: true)
    }
}
