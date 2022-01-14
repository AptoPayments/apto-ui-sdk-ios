//
//  FormRowButtonView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import UIKit

class FormRowImageView: FormRowView {
    private let imageView: UIImageView

    init(imageView: UIImageView, height: CGFloat) {
        self.imageView = imageView
        super.init(showSplitter: false, height: height)
        contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.height.equalTo(height)
            make.top.left.right.bottom.equalTo(self.contentView)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
