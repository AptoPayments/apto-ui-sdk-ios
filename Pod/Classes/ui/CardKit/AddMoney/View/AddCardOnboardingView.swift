//
//  AddCardOnboardingView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 15/6/21.
//

import Foundation

import UIKit
import SnapKit
import AptoSDK

public final class AddCardOnboardingView: UIView {
    let uiConfiguration: UIConfig
    
    private(set) lazy var headerLabel: UILabel = {
        let label = ComponentCatalog.topBarTitleLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        label.font = UITheme2FontProvider(fontDescriptors: nil).topBarTitleBigFont
        label.text = "load_funds.add_card.onboarding.title".podLocalized()
        return label
    }()
    private(set) lazy var firstParagraphLabel: UILabel = {
        let label = ComponentCatalog.formListLabelWith(text: "",
                                                       textAlignment: .left,
                                                       uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        label.font = uiConfiguration.fontProvider.formLabelFont
        label.numberOfLines = 0
        return label
    }()
    private(set) lazy var secondParagraphLabel: UILabel = {
        let label = ComponentCatalog.formListLabelWith(text: "",
                                                       textAlignment: .left,
                                                       uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        label.font = uiConfiguration.fontProvider.formLabelFont
        label.numberOfLines = 0
        return label
    }()
    private(set) lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = uiConfiguration.uiPrimaryColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle("load_funds.add_card.onboarding.primary_cta".podLocalized(), for: .normal)
        button.titleLabel?.font = UITheme2FontProvider(fontDescriptors: nil).mainItemLightFont
        return button
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
        isOpaque = false
        
        [headerLabel, firstParagraphLabel, secondParagraphLabel, actionButton].forEach(addSubview)
        actionButton.layer.cornerRadius = 25
    }
    
    private func setupConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(52)
        }
        firstParagraphLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(headerLabel.snp.bottom).offset(28)
        }
        secondParagraphLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(firstParagraphLabel.snp.bottom).offset(20)
        }
        actionButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalTo(bottomConstraint).inset(34)
        }
    }
    
    // MARK: Public methods
    public func configure(firstParagraph: String, secondParagraph: String) {
        firstParagraphLabel.text = firstParagraph
        secondParagraphLabel.text = secondParagraph
    }
    
    func hideView() {
        [headerLabel, firstParagraphLabel, secondParagraphLabel, actionButton].forEach { view in
            view.alpha = 0
        }
    }
    
    func showView() {
        [headerLabel, firstParagraphLabel, secondParagraphLabel, actionButton].forEach { view in
            view.alpha = 1
        }
    }
}


