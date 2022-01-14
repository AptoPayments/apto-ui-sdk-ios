//
//  ApplicationSummaryScreen.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 07/11/2017.
//
//

import UIKit

class ApplicationSummaryScreen: Screen {
    enum Labels {
        static let ViewControllerTitle = "Confirm Application"
        static let ScrollDownButton = "Scroll Down Button"
        static let AgreeButton = "Agree Button"
    }

    @discardableResult override func waitForScreen() -> Self {
        waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)

        return self
    } // end waitForScreen

    @discardableResult func scrollDown() -> Self {
        tapView(withAccessibilityLabel: Labels.ScrollDownButton)

        return self
    } // end scrollDown

    @discardableResult func agree() -> Self {
        tapView(withAccessibilityLabel: Labels.AgreeButton)

        return self
    } // end agree
}
