//
//  SnapKit.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/1/21.
//

import UIKit
import SnapKit

extension UIView {
    var bottomConstraint: ConstraintItem {
        if #available(iOS 11, *) {
            return self.safeAreaLayoutGuide.snp.bottom
        }
        return self.snp.bottom
    }
}
