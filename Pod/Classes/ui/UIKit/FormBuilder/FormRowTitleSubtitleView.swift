//
//  FormRowTitleSubtitleView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 03/03/16.
//
//

import Foundation

open class FormRowTitleSubtitleView: FormRowView {
    public let titleLabel: UILabel
    public let subtitleLabel: UILabel
    let rightButton: UIButton
    let rightButtonTaHandler: (() -> Void)?

    public init(titleLabel: UILabel,
                subtitleLabel: UILabel,
                rightIcon: UIImage? = nil,
                showSplitter: Bool = false,
                rightButtonAccessibilityLabel: String? = nil,
                rightButtonTaHandler: (() -> Void)? = nil)
    {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        rightButton = UIButton(frame: CGRect.zero)
        rightButton.accessibilityLabel = rightButtonAccessibilityLabel
        self.rightButtonTaHandler = rightButtonTaHandler

        super.init(showSplitter: showSplitter)
        contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.contentView)
        }
        contentView.addSubview(self.subtitleLabel)
        self.subtitleLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.contentView)
            make.top.equalTo(self.titleLabel.snp.bottom)
        }
        guard let rightIcon = rightIcon else {
            return
        }
        rightButton.setImage(rightIcon, for: UIControl.State())
        contentView.addSubview(rightButton)
        rightButton.isHidden = true
        rightButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.width.height.equalTo(self.contentView.snp.height).multipliedBy(0.5)
        }
        rightButton.addTarget(self, action: #selector(FormRowTitleSubtitleView.rightButtonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func presentNonFocusedState() {
        UIView.transition(with: titleLabel,
                          duration: 0.15,
                          options: UIView.AnimationOptions.transitionCrossDissolve,
                          animations: {
                              self.titleLabel.textColor = self.unfocusedColor
                          },
                          completion: nil)
    }

    override func presentFocusedState() {
        UIView.transition(with: titleLabel,
                          duration: 0.15,
                          options: UIView.AnimationOptions.transitionCrossDissolve,
                          animations: {
                              self.titleLabel.textColor = self.focusedColor
                          },
                          completion: nil)
    }

    open func showRightButton() {
        rightButton.isHidden = false
    }

    open func hideRightButton() {
        rightButton.isHidden = true
    }

    @objc func rightButtonTapped() {
        rightButtonTaHandler?()
    }
}
