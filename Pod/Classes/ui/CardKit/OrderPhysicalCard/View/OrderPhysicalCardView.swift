//
//  OrderPhysicalCardView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 23/3/21.
//

import AptoSDK
import SnapKit
import UIKit

final class OrderPhysicalCardView: UIView {
    enum Constants {
        static let buttonsCornerRadius = CGFloat(25)
        static let headerLabelPadding = 20
        static let headerLabelTopMargin = 50
        static let introLabelPadding = 20
        static let introLabelTopMargin = 12
        static let creditCardPadding = 26
        static let creditCardTopMargin = 24
        static let feeInfoTopMargin = 8
        static let feeInfoTopHeight = 55
        static let cancelButtonBottomMargin = 32
        static let actionButtonBottomMargin = -12
        static let buttonPadding = 20
        static let buttonHeight = 50
    }

    let uiConfiguration: UIConfig
    private(set) lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "order_physical_card.order_screen.header".podLocalized()
        label.font = uiConfiguration.fontProvider.topBarTitleBigFont
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        return label
    }()

    private(set) lazy var introLabel: UILabel = {
        let label = ComponentCatalog.boldMessageLabelWith(text: "order_physical_card.order_screen.intro".podLocalized(),
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textTertiaryColor
        label.font = uiConfiguration.fontProvider.itemDescriptionFont
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var creditCardView = AptoCardView()
    private(set) lazy var feeInfoView = ShowInfoView(uiconfig: uiConfiguration)
    private(set) lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = uiConfiguration.uiPrimaryColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("order_physical_card.order_screen_order.order_action".podLocalized(), for: .normal)
        button.titleLabel?.font = UITheme2FontProvider(fontDescriptors: nil).mainItemLightFont
        return button
    }()

    private(set) lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
        button.setTitleColor(.black, for: .normal)
        button.setTitle("order_physical_card.order_screen_order.cancel_action".podLocalized(), for: .normal)
        button.titleLabel?.font = UITheme2FontProvider(fontDescriptors: nil).mainItemLightFont
        return button
    }()

    init(uiconfig: UIConfig) {
        uiConfiguration = uiconfig
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = uiConfiguration.textMessageColor
        [headerLabel, introLabel, creditCardView, feeInfoView, actionButton, cancelButton].forEach(addSubview)

        cancelButton.layer.cornerRadius = Constants.buttonsCornerRadius
        actionButton.layer.cornerRadius = Constants.buttonsCornerRadius
        feeInfoView.alpha = 0
    }

    private func setupConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.headerLabelPadding)
            make.top.equalToSuperview().offset(Constants.headerLabelTopMargin)
        }
        introLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.introLabelPadding)
            make.top.equalTo(headerLabel.snp.bottom).offset(Constants.introLabelTopMargin)
        }
        creditCardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.creditCardPadding)
            make.height.equalTo(creditCardView.snp.width).dividedBy(cardAspectRatio)
            make.top.equalTo(introLabel.snp.bottom).offset(Constants.creditCardTopMargin)
        }
        feeInfoView.snp.makeConstraints { make in
            make.top.equalTo(creditCardView.snp.bottom).offset(Constants.feeInfoTopMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(Constants.feeInfoTopHeight)
        }
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(bottomConstraint).inset(Constants.cancelButtonBottomMargin)
            make.left.right.equalToSuperview().inset(Constants.buttonPadding)
            make.height.equalTo(Constants.buttonHeight)
        }
        actionButton.snp.makeConstraints { make in
            make.bottom.equalTo(cancelButton.snp.top).offset(Constants.actionButtonBottomMargin)
            make.left.right.equalToSuperview().inset(Constants.buttonPadding)
            make.height.equalTo(Constants.buttonHeight)
        }
    }

    // MARK: Public methods

    func configure(card: Card, cardFee: String?) {
        creditCardView.configure(with: card.cardStyle, cardNetwork: card.cardNetwork)
        if let cardFee = cardFee,
           let feeAmount = Double(cardFee.dropFirst()),
           feeAmount > 0
        {
            feeInfoView.configure(with: "order_physical_card.order_screen.order_fee_title".podLocalized(),
                                  valueText: cardFee)
            feeInfoView.alpha = 1
        }
    }

    func viewButtons(enable: Bool) {
        actionButton.isEnabled = enable
        cancelButton.isEnabled = enable
    }
}
