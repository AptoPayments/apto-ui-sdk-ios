//
//  CountryCell.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/05/2019.
//

import AptoSDK
import SnapKit
import UIKit

class CountryCell: UITableViewCell {
    private var styleInitialized = false
    private let flagLabel = UILabel()
    private let nameLabel = UILabel()
    private let selectedImageView = UIImageView()
    private let uncheckedImage = UIImage.imageFromPodBundle("radio-button-unchecked")?.asTemplate()
    private let checkedImage = UIImage.imageFromPodBundle("radio-button-checked")?.asTemplate()

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
        guard !styleInitialized else { return }
        nameLabel.textColor = uiConfig.textPrimaryColor
        nameLabel.font = uiConfig.fontProvider.mainItemRegularFont
        backgroundColor = uiConfig.uiBackgroundPrimaryColor
        contentView.backgroundColor = backgroundColor
        styleInitialized = true
    }

    func set(country: Country) {
        flagLabel.text = country.flag
        nameLabel.text = country.name
    }

    func selected(_ selected: Bool) {
        selectedImageView.image = selected ? checkedImage : uncheckedImage
    }
}

// MARK: - Set up UI

private extension CountryCell {
    func setUpUI() {
        setUpFlagLabel()
        setUpSelectedImageView()
        setUpNameLabel()
    }

    func setUpFlagLabel() {
        contentView.addSubview(flagLabel)
        flagLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(24)
        }
    }

    func setUpSelectedImageView() {
        selectedImageView.image = uncheckedImage
        selectedImageView.contentMode = .scaleToFill
        contentView.addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(32)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
    }

    func setUpNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(flagLabel.snp.right).offset(12)
        }
    }
}
