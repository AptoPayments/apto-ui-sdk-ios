//
//  FormRowSeparatorView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/02/16.
//
//

import AptoSDK
import UIKit

open class FormRowSeparatorView: FormRowView {
    public init(backgroundColor: UIColor, height: CGFloat, showTopLine: Bool = false, showBottomLine: Bool = false) {
        super.init(showSplitter: false, padding: .zero, height: height, maxHeight: height)
        self.backgroundColor = backgroundColor
        if showTopLine {
            let topLine = UIView()
            addSubview(topLine)
            topLine.backgroundColor = colorize(0xD5D5D5, alpha: 1.0)
            topLine.snp.makeConstraints { make in
                make.left.right.equalTo(self)
                make.top.equalTo(self)
                make.height.equalTo(1 / UIScreen.main.scale)
            }
        }
        if showBottomLine {
            let bottomLine = UIView()
            addSubview(bottomLine)
            bottomLine.backgroundColor = colorize(0xD5D5D5, alpha: 1.0)
            bottomLine.snp.makeConstraints { make in
                make.left.right.equalTo(self)
                make.bottom.equalTo(self)
                make.height.equalTo(1 / UIScreen.main.scale)
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func becomeFirstResponder() -> Bool {
        return false
    }
}
