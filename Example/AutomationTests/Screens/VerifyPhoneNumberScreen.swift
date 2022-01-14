//
//  VerifyPhoneNumberScreen.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/08/2017.
//

import Foundation

class VerifyPhoneNumberScreen: Screen {
    enum Labels {
        static let SubmitButton = "Submit PIN Code"
    }

    @discardableResult func input(verificationCode: String) -> Self {
        var code = verificationCode
        var i = 1
        for char in code.characters {
            let text = String(char)
            set(text: text, intoViewWithAccessibilityLabel: "Phone PIN Field (\(i))")
            i = i + 1
        }
        return self
    }

    @discardableResult func submitCode() -> Self {
        tapView(withAccessibilityLabel: Labels.SubmitButton)
        return self
    }
}
