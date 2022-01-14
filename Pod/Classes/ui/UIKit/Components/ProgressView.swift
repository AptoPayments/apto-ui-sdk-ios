//
//  ProgressView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 03/06/16.
//
//

import AptoSDK
import SnapKit

class ProgressView: UIView {
    private let uiConfig: UIConfig
    private let maxValue: Float
    private let progressView: UIView
    var currentValue: Float = 0
    var foregroundColor: UIColor {
        didSet {
            progressView.backgroundColor = foregroundColor
        }
    }

    init(maxValue: Float, uiConfig: UIConfig) {
        self.uiConfig = uiConfig
        self.maxValue = maxValue
        progressView = UIView(frame: CGRect.zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        foregroundColor = uiConfig.uiSecondaryColor
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = uiConfig.uiSecondaryColorDisabled
        progressView.backgroundColor = foregroundColor
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(0)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(progress: Float) {
        guard progress >= 0, progress <= maxValue else {
            return
        }
        currentValue = progress
        UIView.animate(withDuration: 0.4) {
            self.progressView.snp.remakeConstraints { make in
                make.left.top.bottom.equalTo(self)
                make.width.equalTo(self).multipliedBy(self.currentValue / self.maxValue)
            }
            self.layoutIfNeeded()
        }
    }
}
