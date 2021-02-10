//
//  DetailActionView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/1/21.
//

import UIKit
import SnapKit
import AptoSDK

public final class DetailActionView: UIView {
    let uiConfiguration: UIConfig
    
    private lazy var titleLabel: UILabel = {
        let label = ComponentCatalog.boldMessageLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.iconPrimaryColor
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private lazy var subTitleLabel: UILabel = {
        let label = ComponentCatalog.boldMessageLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textSecondaryColor
        label.font = uiConfiguration.fontProvider.itemDescriptionFont
        return label
    }()
    private lazy var chevronImageView: UIImageView = {
        guard let image = UIImage.imageFromPodBundle("row_arrow.png")?.asTemplate() else { return UIImageView() }
        let imageView = UIImageView(image: image)
        imageView.tintColor = uiConfiguration.uiBackgroundPrimaryColor
        return imageView
    }()
    private let dividerView = UIView()
    private let titleText: String
    private let subTitleText: String
    
    init(uiconfig: UIConfig, textTitle: String, textSubTitle: String) {
        self.uiConfiguration = uiconfig
        self.titleText = textTitle
        self.subTitleText = textSubTitle
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        backgroundColor = uiConfiguration.textMessageColor
        dividerView.backgroundColor = uiConfiguration.uiTertiaryColor
        titleLabel.text = titleText.podLocalized()
        subTitleLabel.text = subTitleText.podLocalized()
        
        [titleLabel, subTitleLabel, chevronImageView, dividerView].forEach(addSubview)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(16)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        chevronImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(13)
            make.centerY.equalToSuperview()
        }
        dividerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}


