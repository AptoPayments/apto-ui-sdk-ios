//
//  HeaderTextView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/1/21.
//

import AptoSDK
import SnapKit
import UIKit

public final class HeaderTextView: UIView {
    let uiConfiguration: UIConfig

    private lazy var headerLabel: UILabel = {
        let label = ComponentCatalog.topBarTitleLabelWith(text: "",
                                                          textAlignment: .left,
                                                          uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        return label
    }()

    private let dividerView = UIView()
    private let headerText: String

    init(uiconfig: UIConfig, text: String) {
        uiConfiguration = uiconfig
        headerText = text
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = uiConfiguration.textMessageColor
        isOpaque = false
        dividerView.backgroundColor = uiConfiguration.uiTertiaryColor
        headerLabel.text = headerText

        [headerLabel, dividerView].forEach(addSubview)
    }

    private func setupConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        dividerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
