//
//  ShowInfoView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 27/1/21.
//

import AptoSDK
import Foundation
import SnapKit

public final class ShowInfoView: UIView {
    let uiConfiguration: UIConfig

    private lazy var infoLabel: UILabel = {
        let label = ComponentCatalog.boldMessageLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        label.font = uiConfiguration.fontProvider.formListFont
        return label
    }()

    private(set) lazy var valueLabel: UILabel = {
        let label = ComponentCatalog.boldMessageLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textSecondaryColor
        label.font = uiConfiguration.fontProvider.formListFont
        label.isUserInteractionEnabled = true
        return label
    }()

    private let dividerView = UIView()

    init(uiconfig: UIConfig) {
        uiConfiguration = uiconfig
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Private Methods

    private func setupViews() {
        backgroundColor = uiConfiguration.textMessageColor
        dividerView.backgroundColor = uiConfiguration.uiTertiaryColor

        [infoLabel, valueLabel, dividerView].forEach(addSubview)
    }

    private func setupConstraints() {
        infoLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(infoLabel.snp.centerY)
        }
        dividerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(infoLabel.snp.left)
            make.right.equalTo(valueLabel.snp.right)
            make.height.equalTo(1)
        }
    }

    // MARK: Public Methods

    public func configure(with infoText: String, valueText: String) {
        infoLabel.text = infoText
        valueLabel.text = valueText
    }
}
