//
//  SnapKit.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/1/21.
//

import SnapKit
import UIKit

extension UIView {
    var bottomConstraint: ConstraintItem {
        if #available(iOS 11, *) {
            return self.safeAreaLayoutGuide.snp.bottom
        }
        return snp.bottom
    }

    var snpTopConstraint: ConstraintItem {
        if #available(iOS 11, *) {
            return self.safeAreaLayoutGuide.snp.top
        }
        return snp.top
    }
}
