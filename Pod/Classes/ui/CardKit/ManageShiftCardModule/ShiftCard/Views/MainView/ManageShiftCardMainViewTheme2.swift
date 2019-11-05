//
// ManageShiftCardMainViewTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-12.
//

import UIKit
import AptoSDK
import SnapKit

class ManageShiftCardMainViewTheme2: UIView, CardPresentationProtocol {
  private var isActivateCardFeatureEnabled = false {
    didSet {
      activeStateReceived = true
    }
  }
  private var cardState = FinancialAccountState.inactive {
    didSet {
      creditCardView.set(cardState: cardState)
    }
  }
  private var fundingSourceState: FundingSourceState?
  private var activeStateReceived = false
  private var balanceReceived = false
  private var shouldUpdateTopMessageView = false
  private var topMessageViewType = TopMessageViewType.none {
    didSet {
      shouldUpdateTopMessageView = oldValue != topMessageViewType
    }
  }
  private let gearView = UIImageView(image: UIImage.imageFromPodBundle("btn_card_settings", uiTheme: .theme2))
  private let creditCardView: CreditCardView
  private let backgroundView = UIView()
  private unowned let delegate: ManageShiftCardMainViewDelegate
  private let uiConfiguration: UIConfig
  private var showPhysicalCardActivationMessage = true

  init(uiConfiguration: UIConfig, cardStyle: CardStyle?, delegate: ManageShiftCardMainViewDelegate) {
    self.uiConfiguration = uiConfiguration
    self.delegate = delegate
    self.creditCardView = CreditCardView(uiConfiguration: uiConfiguration, cardStyle: cardStyle)
    super.init(frame: .zero)
    setUpUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func willMove(toWindow newWindow: UIWindow?) {
    // Remove any presented message when the view in removed from the hierarchy
    if newWindow == nil {
      hideMessage(animated: false)
    }
    super.willMove(toWindow: newWindow)
  }

  @objc private func cardTapped() {
    hideMessage(animated: true)
    delegate.cardTapped()
  }

  @objc private func cardSettingsTapped() {
    delegate.cardSettingsTapped()
  }

  @objc private func balanceTapped() {
    delegate.balanceTapped()
  }

  func set(cardHolder: String?) {
    self.creditCardView.set(cardHolder: cardHolder)
  }

  func set(cardNumber: String?) {
    self.creditCardView.set(cardNumber: cardNumber)
  }

  func set(lastFour: String?) {
    self.creditCardView.set(lastFour: lastFour)
  }

  func set(cvv: String?) {
    self.creditCardView.set(cvc: cvv)
  }

  func set(cardNetwork: CardNetwork?) {
    self.creditCardView.set(cardNetwork: cardNetwork)
  }

  func set(expirationMonth: UInt, expirationYear: UInt) {
    self.creditCardView.set(expirationMonth: expirationMonth, expirationYear: expirationYear)
  }

  func set(fundingSource: FundingSource?) {
    fundingSourceState = fundingSource?.state
    balanceReceived = true
    if let fundingSource = fundingSource, fundingSource.balance != nil {
      creditCardView.set(validFundingSource: fundingSource.state == .valid)
      if fundingSource.state == .invalid {
        topMessageViewType = .invalidBalance
        showInvalidBalanceMessage()
      }
    }
    else {
      showNoBalanceMessage()
      creditCardView.set(validFundingSource: false)
    }
  }

  func set(physicalCardActivationRequired: Bool?, showMessage: Bool) {
    showPhysicalCardActivationMessage = showMessage
    // If balance is not valid ignore the physical card activation
    guard topMessageViewType != .invalidBalance || topMessageViewType != .noBalance else { return }
    if physicalCardActivationRequired == true {
      topMessageViewType = .activatePhysicalCard
      showActivatePhysicalCardMessage()
    }
    else {
      topMessageViewType = .none
      if shouldUpdateTopMessageView {
        hideMessage()
      }
    }
  }

  func setSpendable(amount: Amount?, nativeAmount: Amount?) {
  }

  func set(cardState: FinancialAccountState?) {
    if let cardState = cardState {
      self.cardState = cardState
      gearView.isHidden = cardState == .created
    }
    else {
      self.cardState = .inactive
    }
  }

  func set(cardStyle: CardStyle?) {
    creditCardView.set(cardStyle: cardStyle)
  }

  func set(activateCardFeatureEnabled: Bool?) {
    isActivateCardFeatureEnabled = activateCardFeatureEnabled ?? false
  }

  func set(showInfo: Bool?) {
    if let visible = showInfo {
      creditCardView.set(showInfo: visible)
    }
  }

  func scale(factor scaleFactor: CGFloat) {
    layoutBackgroundView(scaleFactor: scaleFactor)
  }
}

// MARK: - Setup UI
private extension ManageShiftCardMainViewTheme2 {
  func setUpUI() {
    backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpCreditCardView()
    setUpGearView()
  }

  func setUpCreditCardView() {
    creditCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
    addSubview(creditCardView)
    creditCardView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.height.equalTo(creditCardView.snp.width).dividedBy(cardAspectRatio)
      make.top.equalToSuperview().offset(12)
      make.bottom.equalToSuperview().inset(16)
    }
    backgroundView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    addSubview(backgroundView)
    layoutBackgroundView(scaleFactor: 0)
    bringSubviewToFront(creditCardView)
  }

  func layoutBackgroundView(scaleFactor: CGFloat) {
    backgroundView.snp.removeConstraints()
    backgroundView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalToSuperview()
      make.height.equalTo(creditCardView).dividedBy(2 + 3 * scaleFactor).offset(12)
    }
  }

  func setUpGearView() {
    gearView.contentMode = .center
    gearView.backgroundColor = uiConfiguration.uiPrimaryColor
    gearView.layer.cornerRadius = 18
    gearView.layer.shadowOffset = CGSize(width: 0, height: 2)
    gearView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
    gearView.layer.shadowOpacity = 1
    gearView.layer.shadowRadius = 4
    gearView.isUserInteractionEnabled = true
    gearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardSettingsTapped)))
    addSubview(gearView)
    gearView.snp.makeConstraints { make in
      make.height.width.equalTo(36)
      make.top.equalToSuperview().offset(6)
      make.right.equalToSuperview().inset(20)
    }
  }

  func showInvalidBalanceMessage() {
    show(message: "invalid-balance.message".podLocalized(),
         title: "invalid-balance.title".podLocalized(),
         animated: false,
         isError: true,
         uiConfig: uiConfiguration) { [unowned self] in
      self.balanceTapped()
    }
  }

  func showNoBalanceMessage() {
    show(message: "no-balance.message".podLocalized(),
         title: "no-balance.title".podLocalized(),
         animated: false,
         isError: true,
         uiConfig: uiConfiguration) { [unowned self] in
      self.balanceTapped()
    }
  }

  func showActivatePhysicalCardMessage() {
    guard showPhysicalCardActivationMessage else { return }
    show(message: "manage_card.activate_physical_card_overlay.message".podLocalized(),
         title: "manage_card.activate_physical_card_overlay.title".podLocalized(),
         animated: false,
         isError: false,
         uiConfig: uiConfiguration) { [unowned self] in
      self.activatePhysicalCard()
    }
  }
}

// MARK: - MessageView actions
extension ManageShiftCardMainViewTheme2 {
  func activatePhysicalCard() {
    delegate.activatePhysicalCardTapped()
  }
}
