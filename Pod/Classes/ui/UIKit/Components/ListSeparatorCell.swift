//
//  ListSeparatorCell.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 16/02/16.
//
//

import Foundation

class ListSeparatorCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
