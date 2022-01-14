//
//  SectionHeaderView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 31/12/2018.
//

import AptoSDK
import SnapKit
import UIKit

class SectionHeaderViewTheme2: UIView {
    private let uiConfig: UIConfig

    init(text: String, uiConfig: UIConfig) {
        self.uiConfig = uiConfig
        super.init(frame: .zero)
        setupUI(text: text)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(text: String) {
        backgroundColor = uiConfig.uiBackgroundSecondaryColor
        setUpLabel(text: text)
        setUpTopDivider()
        setUpBottomDivider()
    }

    private func setUpLabel(text: String) {
        let label = ComponentCatalog.starredSectionTitleLabelWith(text: text,
                                                                  color: uiConfig.textSecondaryColor,
                                                                  uiConfig: uiConfig)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func setUpTopDivider() {
        let topDivider = UIView()
        topDivider.backgroundColor = uiConfig.uiTertiaryColor
        addSubview(topDivider)
        topDivider.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    private func setUpBottomDivider() {
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = uiConfig.uiTertiaryColor
        addSubview(bottomDivider)
        bottomDivider.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
