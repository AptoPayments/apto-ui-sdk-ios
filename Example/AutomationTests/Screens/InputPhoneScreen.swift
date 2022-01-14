//
//  InputPhoneScreen.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 31/10/2017.
//

import UIKit

class InputPhoneScreen: Screen {
    enum Labels {
        static let ViewControllerTitle = "Get Started"
        static let PhoneNumberField = "Phone Number Input Field"
    }

    @discardableResult override func waitForScreen() -> Self {
        waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)

        return self
    } // end waitForScreen

    @discardableResult func input(phoneNumber: String) -> Self {
        enter(text: phoneNumber, intoViewWithAccessibilityLabel: Labels.PhoneNumberField)

        return self
    } // end input(phoneNumber)
}
