//
//  SelectAccountScreen.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 04/11/2017.
//

import UIKit

class SelectAccountScreen: Screen {
    enum Labels {
        static let ViewControllerTitle = "Funding Account"
        static let AddAccountButton = "Add Account Button"
    }

    @discardableResult override func waitForScreen() -> Self {
        waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)

        return self
    } // end waitForScreen

    @discardableResult func addAccount() -> Self {
        tapView(withAccessibilityLabel: Labels.AddAccountButton)

        return self
    } // end selectBankAccount
}
