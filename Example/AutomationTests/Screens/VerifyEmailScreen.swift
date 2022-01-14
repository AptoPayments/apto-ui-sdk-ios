//
//  VerifyEmailScreen.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 21/08/2017.
//

import Foundation

class VerifyEmailScreen: Screen {
    enum Labels {
        static let VerifyEmailExplanation = "Verify Email Explanation"
    }

    @discardableResult override func waitForScreen() -> Self {
        waitForViewWith(accessibilityLabel: Labels.VerifyEmailExplanation)
        return self
    }
}
