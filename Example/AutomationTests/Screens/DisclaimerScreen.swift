//
//  DisclaimerScreen.swift
//  ShiftAutomationTests
//
//  Created by Ivan Oliver Martínez on 06/02/2018.
//

import UIKit

class DisclaimerScreen: Screen {

  struct Labels {
    static let AgreeButton = "Agree"
  }

  @discardableResult override func waitForScreen() -> Self {
    waitForViewWith(accessibilityLabel: Labels.AgreeButton)
    return self
  }

  @discardableResult func agree() -> Self {
    uiTest.tester().tapView(withAccessibilityLabel: Labels.AgreeButton)
    return self
  }

}
