//
//  FormRowDoubleButtonView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 11/02/16.
//
//

import ReactiveKit
import UIKit

class FormRowDoubleButtonView: FormRowView {
    private let disposeBag = DisposeBag()
    private let leftButton: UIButton
    private let rightButton: UIButton

    init(leftButton: UIButton, rightButton: UIButton, leftTapHandler: @escaping () -> Void,
         rightTapHandler: @escaping () -> Void)
    {
        self.leftButton = leftButton
        self.rightButton = rightButton
        super.init(showSplitter: false)
        contentView.addSubview(self.leftButton)
        contentView.addSubview(self.rightButton)
        self.leftButton.snp.makeConstraints { make in
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.rightButton.snp.left).offset(-10)
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
        self.rightButton.snp.makeConstraints { make in
            make.right.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
            make.width.equalTo(self.leftButton.snp.width)
        }
        self.leftButton.reactive.tap.observeNext(with: leftTapHandler).dispose(in: disposeBag)
        self.rightButton.reactive.tap.observeNext(with: rightTapHandler).dispose(in: disposeBag)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
