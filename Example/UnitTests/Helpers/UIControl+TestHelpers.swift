//
//  UIControl+TestHelpers.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/3/21.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0), with: self)
            }
        }
    }
}
