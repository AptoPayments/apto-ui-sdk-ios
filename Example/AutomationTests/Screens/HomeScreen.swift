//
//  HomeScreen.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 20/08/2017.
//

import Foundation

class HomeScreen: Screen {
    enum Labels {
        static let ViewControllerTitle = "Address"
        static let ZipInputField = "ZIP Input Field"
        static let HomeTypeField = "Home Type Picker"
    }

    @discardableResult override func waitForScreen() -> Self {
        waitForViewWith(accessibilityLabel: Labels.ZipInputField)
        waitForViewWith(accessibilityLabel: Labels.HomeTypeField)

        return self
    } // end waitForScreen

    @discardableResult func input(zipCode: String) -> Self {
        return enter(text: zipCode, intoViewWithAccessibilityLabel: Labels.ZipInputField)
    } // end input(zipCode)

    @discardableResult func select(homeType: String) -> Self {
        selectPicker(value: homeType, intoViewWithAccessibilityLabel: Labels.HomeTypeField)

        return self
    } // end select(homeType)
}
