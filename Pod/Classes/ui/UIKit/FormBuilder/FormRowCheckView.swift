//
//  FormRowRadioView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 27/02/16.
//
//

import Bond
import UIKit

class FormRowCheckView: FormRowView {
    let label: UILabel
    let checkIcon: UIImageView
    var checked: Bool = false {
        didSet {
            checked ? showCheckedState() : showUncheckedState()
        }
    }

    init(label: UILabel, showSplitter: Bool = false, height: CGFloat = 44) {
        self.label = label
        checkIcon = UIImageView(image: UIImage.imageFromPodBundle("empty_tick_circled.png"))
        super.init(showSplitter: showSplitter, height: height)
        contentView.addSubview(label)
        contentView.addSubview(checkIcon)
        checkIcon.snp.makeConstraints { make in
            make.left.equalTo(contentView)
            make.top.equalTo(label)
            make.width.height.equalTo(20)
        }
        checkIcon.isUserInteractionEnabled = true
        checkIcon.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(FormRowCheckView.switchValue)))
        label.snp.makeConstraints { make in
            make.left.equalTo(checkIcon.snp.right).offset(15)
            make.top.equalTo(contentView).offset(7)
            make.right.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-7)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _bndValue: Observable<Bool>?
    var bndValue: Observable<Bool> {
        if let bndValue = _bndValue {
            return bndValue
        } else {
            let bndValue = Observable<Bool>(checked)
            _ = bndValue.observeNext { [weak self] (value: Bool) in
                self?.checked = value
            }
            _bndValue = bndValue
            return bndValue
        }
    }

    // MARK: - Private methods and attributes

    fileprivate func showCheckedState() {
        DispatchQueue.main.async {
            self.checkIcon.image = UIImage.imageFromPodBundle("blue_tick_circled.png")?.asTemplate()
        }
    }

    fileprivate func showUncheckedState() {
        DispatchQueue.main.async {
            self.checkIcon.image = UIImage.imageFromPodBundle("empty_tick_circled.png")
        }
    }

    @objc func switchValue() {
        bndValue.send(!bndValue.value)
    }
}
