//
// CardMonthlyStatsGraphSummaryView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 11/01/2019.
//

import UIKit
import AptoSDK
import SnapKit

class CardMonthlyStatsGraphSummaryView: UIView {
  private let uiConfig: UIConfig
  private let titleLabel: UILabel
  private let amountLabel: UILabel
  private let differenceLabel: PaddingLabel

  init(uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    self.titleLabel = ComponentCatalog.timestampLabelWith(text: "", textAlignment: .center, uiConfig: uiConfig)
    self.amountLabel = ComponentCatalog.mainItemRegularLabelWith(text: "", textAlignment: .center, uiConfig: uiConfig)
    self.differenceLabel = PaddingLabel(frame: .zero)
    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(title: String, amount: Amount, difference: Double?) {
    titleLabel.text = title
    amountLabel.text = amount.text
    set(difference: difference)
  }

  private func set(difference: Double?) {
    guard let difference = difference else {
      differenceLabel.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      return
    }
    differenceLabel.snp.updateConstraints { make in
      make.height.equalTo(24)
    }
    differenceLabel.text = difference > 0 ? "+\(difference)%" : "\(difference)%"
    differenceLabel.backgroundColor = difference > 0 ? uiConfig.statsDifferenceIncreaseBackgroundColor
      : uiConfig.statsDifferenceDecreaseBackgroundColor
  }
}

// MARK: - Set up UI
private extension CardMonthlyStatsGraphSummaryView {
  func setUpUI() {
    backgroundColor = .clear
    setUpTitleLabel()
    setUpAmountLabel()
    setUpDifferenceLabel()
  }

  func setUpTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
    }
  }

  func setUpAmountLabel() {
    addSubview(amountLabel)
    amountLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
    }
  }

  func setUpDifferenceLabel() {
    addSubview(differenceLabel)
    differenceLabel.font = uiConfig.fontProvider.sectionTitleFont
    differenceLabel.textColor = uiConfig.textMessageColor
    differenceLabel.textAlignment = .center
    differenceLabel.layer.cornerRadius = 12
    differenceLabel.layer.masksToBounds = true
    differenceLabel.snp.makeConstraints { make in
      make.top.equalTo(amountLabel.snp.bottom).offset(4)
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(24)
    }
  }
}
