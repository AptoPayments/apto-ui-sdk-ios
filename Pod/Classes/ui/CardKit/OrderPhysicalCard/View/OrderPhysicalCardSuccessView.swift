//
//  OrderPhysicalCardSuccessView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 24/3/21.
//

import Foundation

import UIKit
import SnapKit
import AptoSDK

final class OrderPhysicalCardSuccessView: UIView {
    struct Constants {
        static let crediCardPadding = 26.0
        static let crediCardTopMargin = 84.0
        static let titlePadding = 20.0
        static let titleTopMargin = 39.0
        static let descriptionPadding = 20.0
        static let descriptionTopMargin = 16.0
        static let actionButtonPadding = 20.0
        static let actionButtonHeight = 50.0
        static let actionButtonBottonMargin = -34.0
    }
    let uiConfiguration: UIConfig
    private(set) lazy var creditCardView = AptoCardView()
    private(set) lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = uiConfiguration.uiPrimaryColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("order_physical_card.done".podLocalized(), for: .normal)
        button.titleLabel?.font = UITheme2FontProvider(fontDescriptors: nil).mainItemLightFont
        return button
    }()
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "order_physical_card.success_title".podLocalized()
        label.font = uiConfiguration.fontProvider.topBarTitleBigFont
        label.textAlignment = .center
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        return label
    }()
    private(set) lazy var descriptionLabel: UILabel = {
        let label = ComponentCatalog.boldMessageLabelWith(text: "order_physical_card.success_description".podLocalized(),
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textTertiaryColor
        label.font = uiConfiguration.fontProvider.mainItemRegularFont
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(uiconfig: UIConfig) {
        self.uiConfiguration = uiconfig
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        backgroundColor = uiConfiguration.textMessageColor
        [creditCardView, titleLabel, descriptionLabel, actionButton].forEach(addSubview)
        
        actionButton.layer.cornerRadius = 25
    }
    
    private func setupConstraints() {
        creditCardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.crediCardPadding)
            make.height.equalTo(creditCardView.snp.width).dividedBy(cardAspectRatio)
            make.top.equalToSuperview().offset(Constants.crediCardTopMargin)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.titlePadding)
            make.top.equalTo(creditCardView.snp.bottom).offset(Constants.titleTopMargin)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.descriptionPadding)
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.descriptionTopMargin)
        }
        actionButton.snp.makeConstraints { make in
            make.bottom.equalTo(bottomConstraint).offset(Constants.actionButtonBottonMargin)
            make.left.right.equalToSuperview().inset(Constants.actionButtonPadding)
            make.height.equalTo(Constants.actionButtonHeight)
        }
    }

    // MARK: Public methods
    func configure(card: Card) {
        creditCardView.configure(with: card.cardStyle, cardNetwork: card.cardNetwork)
    }
}
