//
// BalanceViewTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-11.
//

import UIKit
import AptoSDK
import SnapKit

class BalanceViewTheme2: BalanceViewProtocol {
  private let balanceLabel = UILabel()
  private let balanceExplanation: UILabel
  private let balanceBitCoins = UILabel()
  private let refreshImageView = UIImageView(frame: .zero)
  private var showBalance = false {
    didSet {
      let hideBalanceInfo = !showBalance
      balanceExplanation.isHidden = hideBalanceInfo
      balanceLabel.isHidden = hideBalanceInfo
    }
  }
  private var showNativeBalance = false {
    didSet {
      balanceBitCoins.isHidden = !showNativeBalance
    }
  }

  private let uiConfiguration: UIConfig
  private var fundingSource: FundingSource?

  init(uiConfiguration: UIConfig) {
    let label = "manage_card.balance.total_balance".podLocalized()
    self.balanceExplanation = ComponentCatalog.starredSectionTitleLabelWith(text: label, uiConfig: uiConfiguration)
    self.uiConfiguration = uiConfiguration
    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(fundingSource: FundingSource) {
    self.refreshImageView.isHidden = false
    self.fundingSource = fundingSource
    guard fundingSource.state == .valid else {
      showInvalidBalance()
      return
    }
    showBalanceIfPresent(in: fundingSource)
  }

  func set(spendableToday: Amount?, nativeSpendableToday: Amount?) {
  }

  func set(imageURL: String?) {
    guard let string = imageURL, let url = URL(string: string) else {
      refreshImageView.image = nil
      return
    }
    refreshImageView.setImageUrl(url)
  }

  func scale(factor scaleFactor: CGFloat) {
    scaleLabel(label: balanceLabel, maxSize: 26, minSize: 18, scaleFactor: scaleFactor)
    scaleLabel(label: balanceBitCoins, maxSize: 16, minSize: 14, scaleFactor: scaleFactor)
    scaleLabel(label: balanceExplanation, maxSize: 12, minSize: 0, scaleFactor: scaleFactor)
    let newAlpha: CGFloat = max(1 - 2.5 * scaleFactor, 0)
    balanceExplanation.alpha = newAlpha
    refreshImageView.alpha = newAlpha
  }

  private func scaleLabel(label: UILabel, maxSize: CGFloat, minSize: CGFloat, scaleFactor: CGFloat) {
    let descriptor = label.font.fontDescriptor
    label.font = UIFont(descriptor: descriptor, size: maxSize - ((maxSize - minSize) * scaleFactor))
  }
}

// MARK: - Update labels
private extension BalanceViewTheme2 {
  func showBalanceIfPresent(in fundingSource: FundingSource) {
    if let balance = fundingSource.balance {
      balanceLabel.text = balance.text
      showBalance = true
    }
    else {
      showBalance = false
    }
    if let custodianWallet = fundingSource as? CustodianWallet,
       let balance = fundingSource.balance,
       !balance.sameCurrencyThan(amount: custodianWallet.nativeBalance) {
      balanceBitCoins.text = " ≈ " + custodianWallet.nativeBalance.text
      showNativeBalance = true
    }
    else {
      showNativeBalance = false
    }
  }

  func showInvalidBalance() {
    let emptyBalance = "manage_card.balance.invalid_balance.title".podLocalized()
    balanceLabel.text = emptyBalance
    balanceBitCoins.text = ""
    showBalance = true
    showNativeBalance = false
  }
}

// MARK: - Setup UI
private extension BalanceViewTheme2 {
  func setUpUI() {
    backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    setUpBalanceExplanation()
    setUpBalanceLabel()
    setUpBalanceBitCoins()
    setUpRefreshImageView()
  }

  func setUpBalanceExplanation() {
    addSubview(balanceExplanation)
    balanceExplanation.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().offset(8)
    }
  }

  func setUpBalanceLabel() {
    balanceLabel.font = uiConfiguration.fontProvider.amountBigFont
    balanceLabel.textColor = uiConfiguration.textTopBarColor
    balanceLabel.textAlignment = .left
    addSubview(balanceLabel)
    balanceLabel.snp.makeConstraints { make in
      make.left.equalTo(balanceExplanation)
      make.top.equalTo(balanceExplanation.snp.bottom).offset(6)
      make.bottom.equalToSuperview().inset(8)
    }
  }

  func setUpBalanceBitCoins() {
    balanceBitCoins.font = uiConfiguration.fontProvider.subCurrencyFont
    balanceBitCoins.textColor = uiConfiguration.textTopBarColor.withAlphaComponent(0.7)
    balanceBitCoins.textAlignment = .left
    addSubview(balanceBitCoins)
    balanceBitCoins.snp.makeConstraints { make in
      make.left.equalTo(balanceLabel.snp.right)
      make.bottom.equalTo(balanceLabel)
    }
  }

  func setUpRefreshImageView() {
    refreshImageView.isHidden = true
    addSubview(refreshImageView)
    refreshImageView.snp.makeConstraints { make in
      make.left.equalTo(balanceBitCoins.snp.right).offset(8)
      make.bottom.equalTo(balanceBitCoins)
      make.width.equalTo(24)
      make.height.equalTo(20)
    }
  }
}
