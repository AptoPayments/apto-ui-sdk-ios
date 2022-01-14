//
//  TransactionAdjustmentViewTheme2.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 31/12/2018.
//

import AptoSDK
import SnapKit
import UIKit

class TransactionAdjustmentViewTheme2: UIView {
    private let titleLabel: UILabel
    private let valuesContainerView = UIView()
    private let uiConfiguration: UIConfig

    init(uiConfiguration: UIConfig) {
        self.uiConfiguration = uiConfiguration
        titleLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", uiConfig: uiConfiguration)

        super.init(frame: .zero)
        setUpUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(title: String?,
             exchangeRate: String?,
             amount: String?,
             fee: String?)
    {
        titleLabel.text = title
        let values: [String] = [amount, exchangeRate, fee].compactMap { $0 }
        layout(values)
    }
}

// MARK: - Set up UI

private extension TransactionAdjustmentViewTheme2 {
    func setUpUI() {
        setUpTitleLabel()
        setUpValuesContainer()
    }

    func setUpTitleLabel() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview()
        }
    }

    func setUpValuesContainer() {
        addSubview(valuesContainerView)
        valuesContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.bottom.right.equalToSuperview()
        }
    }

    func layout(_ values: [String]) {
        var previousLabel: UILabel?
        let lastValue = values.last
        for value in values {
            let label = ComponentCatalog.instructionsLabelWith(text: value,
                                                               textAlignment: .left,
                                                               uiConfig: uiConfiguration)
            label.textColor = uiConfiguration.textTertiaryColor
            valuesContainerView.addSubview(label)
            label.snp.makeConstraints { make in
                if let previousLabel = previousLabel {
                    make.top.equalTo(previousLabel.snp.bottom).offset(6)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.right.equalToSuperview()
                if value == lastValue {
                    make.bottom.equalToSuperview().inset(8)
                }
            }
            previousLabel = label
        }
    }
}
