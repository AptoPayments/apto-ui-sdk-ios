//
//  ViewWrapperCell.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 03/09/2018.
//
//

import SnapKit
import UIKit

class ViewWrapperCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
    }

    func set(view: UIView) {
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
