//
// TitleSubtitleToastView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-17.
//

import AptoSDK
import Foundation
import SnapKit

class TitleSubtitleToast: ToastProtocol {
    var title: String?
    var message: String
    var backgroundColor: UIColor
    var duration: Double?
    var minimumHeight: CGFloat? = 100
    var isUserInteractionEnabled: Bool = true
    var target: ToastDelegate?
    var style: ToastStyle = .bottomToTop

    init(title: String?, message: String, backgroundColor: UIColor, duration: Double?, delegate: ToastDelegate?) {
        self.title = title
        self.message = message
        self.backgroundColor = backgroundColor
        target = delegate
        self.duration = duration
    }
}

class TitleSubtitleToastView: UIView, ToastViewProtocol {
    private let titleLabel: UILabel
    private let messageLabel: UILabel
    private let uiConfig: UIConfig
    private let buttonContainerView = UIView()
    private let closeButton: UIButton

    var tapHandler: (() -> Void)?
    var onToastViewDismissed: (() -> Void)?

    init(uiConfig: UIConfig, onMessageDismissed: (() -> Void)? = nil) {
        self.uiConfig = uiConfig
        titleLabel = ComponentCatalog.sectionTitleLabelWith(text: "", uiConfig: uiConfig)
        messageLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", multiline: true, uiConfig: uiConfig)
        closeButton = UIButton(type: .custom)
        onToastViewDismissed = onMessageDismissed
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func nib() -> ToastViewProtocol? {
        return self
    }

    func configure(with toast: ToastProtocol) {
        guard let toastConfig = toast as? TitleSubtitleToast else { return }
        backgroundColor = toastConfig.backgroundColor
        closeButton.tintColor = toastConfig.backgroundColor
        buttonContainerView.isHidden = (toastConfig.duration != nil)
        closeButton.isHidden = (toastConfig.duration != nil)
        titleLabel.text = toastConfig.title
        messageLabel.text = toastConfig.message
        setUpUI(toastConfig: toastConfig)
    }

    // MARK: - Private methods

    private func setUpUI(toastConfig: TitleSubtitleToast) {
        setUpMessageLabel(toastConfig: toastConfig)
        setUpButtonContainer()
        setUpCloseButton()
        setUpTitleLabel(toastConfig: toastConfig)
    }

    private func setUpMessageLabel(toastConfig: TitleSubtitleToast) {
        addSubview(messageLabel)
        messageLabel.textColor = uiConfig.textMessageColor
        let isTitleHidden: Bool = toastConfig.title == nil
        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.right.equalToSuperview().inset(isTitleHidden ? 50 : 24)
            make.bottom.equalToSuperview().inset(52)
            if isTitleHidden {
                make.top.equalToSuperview().offset(24)
            }
        }
    }

    private func setUpButtonContainer() {
        buttonContainerView.backgroundColor = .clear
        addSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(16)
        }
        buttonContainerView.addTapGestureRecognizer {
            UIApplication.topViewController()?.dismissToast(true)
        }
    }

    private func setUpCloseButton() {
        buttonContainerView.addSubview(closeButton)
        let image = UIImage.imageFromPodBundle("top_close_default@2x")?.asTemplate()
        closeButton.setImage(image, for: .normal)
        closeButton.contentMode = .center
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        closeButton.backgroundColor = uiConfig.textMessageColor.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 10
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.center.equalToSuperview()
        }
        closeButton.addTapGestureRecognizer {
            UIApplication.topViewController()?.dismissToast(true)
        }
    }

    private func setUpTitleLabel(toastConfig: TitleSubtitleToast) {
        guard toastConfig.title != nil else { return }
        addSubview(titleLabel)
        titleLabel.textColor = uiConfig.textMessageColor
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(messageLabel)
            make.right.equalTo(closeButton.snp.left).offset(-16)
            make.bottom.equalTo(messageLabel.snp.top).offset(-8)
            make.top.equalToSuperview().offset(26)
        }
    }
}

extension TitleSubtitleToastView: ToastDelegate {
    public func toastDidTouchUpInside(_: ToastProtocol) {
        tapHandler?()
    }

    public func toastDismissed(_: ToastProtocol) {
        onToastViewDismissed?()
    }
}
