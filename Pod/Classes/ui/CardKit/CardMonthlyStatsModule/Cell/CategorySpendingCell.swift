//
//  CategorySpendingCell.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/01/2019.
//

import AptoSDK
import SnapKit
import UIKit

class CategorySpendingCell: UITableViewCell {
    private let iconBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let amountLabel = UILabel()
    private let bottomDividerView = UIView()
    private var styleInitialized = false
    private var uiConfig: UIConfig?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpUI()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUIConfig(_ uiConfig: UIConfig) {
        self.uiConfig = uiConfig
        guard !styleInitialized else { return }
        contentView.backgroundColor = uiConfig.uiBackgroundSecondaryColor
        iconBackgroundView.backgroundColor = isHighlighted ? uiConfig.uiPrimaryColor : uiConfig.uiTertiaryColor
        iconImageView.tintColor = isHighlighted ? uiConfig.iconTertiaryColor : uiConfig.iconSecondaryColor
        descriptionLabel.font = uiConfig.fontProvider.mainItemRegularFont
        descriptionLabel.textColor = uiConfig.textPrimaryColor
        amountLabel.font = uiConfig.fontProvider.amountSmallFont
        amountLabel.textColor = uiConfig.textPrimaryColor
        bottomDividerView.backgroundColor = uiConfig.uiTertiaryColor
        styleInitialized = true
    }

    func set(image: UIImage?, categoryName: String?, amount: Amount) {
        iconBackgroundView.isHidden = false
        amountLabel.isHidden = false
        descriptionLabel.isHidden = false
        iconImageView.image = image?.asTemplate()
        amountLabel.text = amount.text
        descriptionLabel.text = categoryName?.capitalized
    }

    func highlight(_ highlighted: Bool) {
        guard let uiConfig = uiConfig else { return }
        iconBackgroundView.backgroundColor = highlighted ? uiConfig.uiPrimaryColor : uiConfig.uiTertiaryColor
        iconImageView.tintColor = highlighted ? uiConfig.iconTertiaryColor : uiConfig.iconSecondaryColor
    }
}

// MARK: - Set up UI

private extension CategorySpendingCell {
    func setUpUI() {
        setUpIcon()
        let view = createContentView()
        setUpAmountLabel(superview: view)
        setUpDescriptionLabel(superview: view)
        setUpBottomDivider()
    }

    func setUpIcon() {
        contentView.addSubview(iconBackgroundView)
        iconBackgroundView.layer.cornerRadius = 20
        iconBackgroundView.isHidden = true
        iconBackgroundView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(19)
            make.bottom.equalToSuperview().inset(13)
        }
        iconImageView.contentMode = .center
        iconBackgroundView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.center.equalToSuperview()
        }
    }

    private func createContentView() -> UIView {
        let view = UIView()
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.equalTo(iconBackgroundView.snp.right).offset(16)
            make.right.equalTo(self).inset(20)
            make.top.equalTo(self).inset(17)
            make.bottom.equalTo(self).inset(15)
        }
        return view
    }

    func setUpAmountLabel(superview: UIView) {
        amountLabel.isHidden = true
        amountLabel.textAlignment = .right
        superview.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
        }
    }

    func setUpDescriptionLabel(superview: UIView) {
        descriptionLabel.isHidden = true
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        superview.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.right.equalTo(amountLabel.snp.left).offset(-24)
        }
    }

    func setUpBottomDivider() {
        contentView.addSubview(bottomDividerView)
        bottomDividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(iconBackgroundView.snp.right).offset(16)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
