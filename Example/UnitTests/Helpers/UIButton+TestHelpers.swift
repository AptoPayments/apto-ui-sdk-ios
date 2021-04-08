//
//  UIButton+TestHelpers.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/3/21.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
