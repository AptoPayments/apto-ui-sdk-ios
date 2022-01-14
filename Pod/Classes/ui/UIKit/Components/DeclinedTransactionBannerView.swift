//
// DeclinedTransactionBannerView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 03/07/2019.
//

import AptoSDK
import SnapKit
import UIKit

class DeclinedTransactionBannerView: UIView {
    private let uiConfig: UIConfig
    private let imageView = UIImageView(image: UIImage.imageFromPodBundle("declined-icon")?.asTemplate())
    private let titleLabel: UILabel
    private let descriptionLabel: UILabel

    init(declineReason: String, uiConfig: UIConfig) {
        self.uiConfig = uiConfig
        let title = "transaction_details.basic_info.declined_transaction_banner.title".podLocalized()
        titleLabel = ComponentCatalog.sectionTitleLabelWith(text: title, uiConfig: uiConfig)
        descriptionLabel = ComponentCatalog.mainItemRegularLabelWith(text: declineReason, multiline: true,
                                                                     uiConfig: uiConfig)
        super.init(frame: .zero)
        setUpUI()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        backgroundColor = uiConfig.uiErrorColor
        layer.cornerRadius = 8
        setUpImageView()
        setUpTitleLabel()
        setUpDescriptionLabel()
    }

    private func setUpImageView() {
        addSubview(imageView)
        imageView.tintColor = uiConfig.textMessageColor
        imageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
            make.width.height.equalTo(40)
        }
    }

    private func setUpTitleLabel() {
        addSubview(titleLabel)
        titleLabel.textColor = uiConfig.textMessageColor
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(imageView.snp.right).offset(12)
        }
    }

    private func setUpDescriptionLabel() {
        addSubview(descriptionLabel)
        descriptionLabel.textColor = uiConfig.textMessageColor
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
