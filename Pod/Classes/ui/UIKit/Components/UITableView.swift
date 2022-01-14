//
//  UITableView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 19/03/2018.
//

import SnapKit
import UIKit

extension UITableView {
    /// Set table header view & layout constraints.
    func setTableHeaderView(headerView: UIView) {
        tableHeaderView = headerView
        headerView.snp.makeConstraints { make in
            make.top.left.right.width.equalTo(self)
        }
    }
}
