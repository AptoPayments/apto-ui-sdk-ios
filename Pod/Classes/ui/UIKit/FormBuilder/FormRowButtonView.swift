//
//  FormRowButtonView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import UIKit

open class FormRowButtonView: FormRowView {
    let button: UIButton

    public init(button: UIButton) {
        self.button = button
        super.init(showSplitter: false)
        contentView.addSubview(self.button)
        self.button.snp.makeConstraints { make in
            make.left.right.equalTo(self.contentView).inset(24)
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
