//
//  GrossIncomeScreen.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//

import UIKit

class GrossIncomeScreen: Screen {
    enum Labels {
        static let ViewControllerTitle = "Income"
        static let GrossIncomeSliderField = "Gross Income Slider"
    }

    @discardableResult override func waitForScreen() -> Self {
        waitForViewWith(accessibilityLabel: Labels.ViewControllerTitle)
        waitForViewWith(accessibilityLabel: Labels.GrossIncomeSliderField)

        return self
    } // end waitForScreen

    @discardableResult func select(grossIncome: Int) -> Self {
        return selectSlider(value: grossIncome, intoViewWithAccessibilityLabel: Labels.GrossIncomeSliderField)
    } // end select(grossIncome)
}
