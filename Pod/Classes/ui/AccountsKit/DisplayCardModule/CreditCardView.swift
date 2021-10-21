//
//  CreditCardView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 29/11/2016.
//
//

import Foundation
import AptoSDK
import SnapKit
import UIKit
import AptoPCISDK
 
let cardAspectRatio = 1.585772508336421
let nameOnCardMaxLength = 23

public class CreditCardView: UIView {
  private let uiConfiguration: UIConfig
  private var cardStyle: CardStyle?
  // Container View
  private var showingBack = false
  private let logos: [CardNetwork: UIImage?] = [
    .visa: UIImage.imageFromPodBundle("card_network_visa")?.asTemplate(),
    .mastercard: UIImage.imageFromPodBundle("card_network_mastercard")?.asTemplate(),
    .amex: UIImage.imageFromPodBundle("card_logo_amex"),
    .other: nil
  ]

  // MARK: - Front View
  private let frontView = UIImageView()
  private let imageView = UIImageView()
  private let lockedView = UIView()
  private let lockImageView = UIImageView(image: UIImage.imageFromPodBundle("card-locked-icon"))
  private let pciView = PCIView()
  
  // MARK: - Back View
  private let backView = UIView()
  private let backImage = UIImageView()
  private let cvc = UIFormattedLabel()
  private let backLine = UIView()

  // MARK: - State
  private var cardState: FinancialAccountState = .active
  private var cardNetwork: CardNetwork?
  private var cardInfoShown = false
  private var hasValidFundingSource = true
    private var lastPCIConfiguration: PCIConfiguration?
    
  public var textColor: UIColor = .white {
    didSet {
      imageView.tintColor = textColor
    }
  }

    private(set) var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

  // MARK: - Lifecycle
  public init(uiConfiguration: UIConfig, cardStyle: CardStyle?) {
    self.uiConfiguration = uiConfiguration
    self.cardStyle = cardStyle
    super.init(frame: .zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.layer.cornerRadius = 10
    setUpShadow()
    setupFrontView()
    setupBackView()
    setupCardLogo()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public methods
  
  func configure(with pciConfiguration: PCIConfiguration) {
      if let lastConfiguration = lastPCIConfiguration,
         lastConfiguration == pciConfiguration {
          return
      }
      lastPCIConfiguration = pciConfiguration
      
      addSubview(pciView)
      pciView.snp.makeConstraints { constraints in
          constraints.edges.equalToSuperview()
      }
      
      
      let configAuth = PCIConfigAuth(cardId: pciConfiguration.cardId,
                                     apiKey: pciConfiguration.apiKey,
                                     userToken: pciConfiguration.userToken,
                                     environment: pciConfiguration.environment.pciEnvironment())
      let configCard = PCIConfigCard(lastFour: pciConfiguration.lastFour,
                                     nameOnCard: pciConfiguration.name)
      let config = PCIConfig(configAuth: configAuth,
                             configCard: configCard,
                             theme: "light")
      pciView.initialise(config: config)
      
      pciView.alertTexts = [
        "inputCode.message": "credit_card_view.input_code.message".podLocalized(),
        "inputCode.okAction": "credit_card_view.input_code.ok_action".podLocalized(),
        "inputCode.cancelAction": "credit_card_view.input_code.cancel_action".podLocalized(),
        "wrongCode.message": "credit_card_view.wrong_code.message".podLocalized(),
        "wrongCode.okAction": "credit_card_view.wrong_code.ok_action".podLocalized()
      ]
      let configStyle = PCIConfigStyle(textColor:  "#\(textColor.toHex ?? "ffffff")")
      pciView.setStyle(style: configStyle)
  }

  public func set(cardState: FinancialAccountState) {
    self.cardState = cardState
    updateCard()
  }

  public func set(showInfo: Bool) {
    self.cardInfoShown = showInfo
    updateCard()
  }

  public func set(cardNetwork: CardNetwork?) {
    self.cardNetwork = cardNetwork
    updateCard()
  }

  public func set(validFundingSource: Bool) {
    self.hasValidFundingSource = validFundingSource
    updateCardEnabledState()
  }

  public func set(cardStyle: CardStyle?) {
    self.cardStyle = cardStyle
    updateCardStyle()
  }

  func didBeginEditingCVC() {
    if !showingBack {
      flip()
      showingBack = true
    }
  }

  func didEndEditingCVC() {
    if showingBack {
      flip()
      showingBack = false
    }
  }

  // MARK: - Private methods

  fileprivate func flip() {
    var showingSide: UIView = frontView
    var hiddenSide: UIView = backView
    if showingBack {
      (showingSide, hiddenSide) = (backView, frontView)
    }
    UIView.transition(from: showingSide,
                      to: hiddenSide,
                      duration: 0.7,
                      options: [.transitionFlipFromRight, .showHideTransitionViews],
                      completion: nil)
  }

  fileprivate func set(cardNetwork: CardNetwork, enabled: Bool, alpha: CGFloat) {
    UIView.animate(withDuration: 2) {
      self.imageView.tintColor = self.textColor
      self.imageView.image = self.logos[cardNetwork]! // swiftlint:disable:this force_unwrapping
    }
  }
}

// MARK: - Setup UI
private extension CreditCardView {
  func setUpShadow() {
    let height = 4
    layer.shadowOffset = CGSize(width: 0, height: height)
    layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    layer.shadowOpacity = 1
    layer.shadowRadius = 8
  }

  func setupFrontView() {
    frontView.translatesAutoresizingMaskIntoConstraints = false
    frontView.layer.cornerRadius = 10
    frontView.clipsToBounds = true
    self.addSubview(frontView)
    frontView.isHidden = false
    frontView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self)
    }
    setUpImageView()
    setUpLockView()
  }

  func setUpImageView() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .bottomRight
    frontView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.width.equalTo(60)
      make.height.equalTo(40)
      make.right.equalTo(frontView).inset(20)
      make.bottom.equalTo(frontView).inset(16)
    }
  }

  func setUpLockView() {
    lockedView.backgroundColor = .black
    lockedView.alpha = 0.7
    lockedView.layer.cornerRadius = layer.cornerRadius
    addSubview(lockedView)
    lockedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    setUpLockImageView()
  }

    private func setupCardLogo() {
        logoImageView.layer.masksToBounds = true
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(56)
            make.height.equalTo(44)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(30)
        }
    }
    
  func setUpLockImageView() {
    addSubview(lockImageView)
    lockImageView.contentMode = .center
    lockImageView.tintColor = .white
    lockImageView.alpha = 1
    lockImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setupBackView() {
    backView.translatesAutoresizingMaskIntoConstraints = false
    backView.layer.cornerRadius = 10
    backView.clipsToBounds = true
    self.addSubview(backView)
    backView.isHidden = true
    backView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self)
    }
    setUpBackLine()
    setUpCVC()
  }

  func setUpBackLine() {
    backLine.translatesAutoresizingMaskIntoConstraints = false
    backLine.backgroundColor = colorize(0x000000)
    backView.addSubview(backLine)
    backLine.snp.makeConstraints { make in
      make.top.equalTo(backView).offset(20)
      make.centerX.equalTo(backView)
      make.width.equalTo(300)
      make.height.equalTo(50)
    }
  }

  func setUpCVC() {
    cvc.translatesAutoresizingMaskIntoConstraints = false
    cvc.formattingPattern = "***"
    cvc.backgroundColor = textColor
    cvc.textAlignment = .center
    backView.addSubview(cvc)
    cvc.snp.makeConstraints { make in
      make.top.equalTo(backLine.snp.bottom).offset(10)
      make.width.equalTo(50)
      make.height.equalTo(25)
      make.right.equalTo(backView).inset(10)
    }
  }
}

// MARK: - Update card info
private extension CreditCardView {
  func updateCard() {
    updateCardInfo()
    updateCardEnabledState()
    updateCardNetwork()
  }

  func updateCardInfo() {
    if !self.cardInfoShown {
      hideCardInfo()
    }
    else {
      showCardInfo()
    }
  }

  func hideCardInfo() {
    pciView.hidePCIData()
  }

  func showCardInfo() {
    pciView.showPCIData()
  }

  func updateCardEnabledState() {
    if cardState == .active && hasValidFundingSource {
      setUpEnabledCard()
    }
    else {
      setUpDisabledCard()
    }
  }

  func updateCardStyle() {
    guard let cardStyle = cardStyle else {
      return
    }
    UIView.animate(withDuration: 2) { [weak self] in
      switch cardStyle.background {
      case .color(let cardColor):
        self?.backgroundColor = cardColor
        self?.imageView.isHidden = false
        self?.frontView.image = nil
      case .image(let url):
        self?.frontView.setImageUrl(url)
        self?.imageView.isHidden = true
      }
      if let rawColor = cardStyle.textColor, let color = UIColor.colorFromHexString(rawColor) {
        self?.textColor = color
        self?.pciView.setStyle(style: PCIConfigStyle(textColor: "#\(rawColor)"))
      }
        if let logo = cardStyle.cardLogo {
            self?.logoImageView.setImageUrl(logo)
        }
    }
  }

  func setUpEnabledCard() {
    lockedView.isHidden = true
    lockImageView.isHidden = true
  }

  func setUpDisabledCard() {
    lockImageView.image = lockedImage()
    lockedView.isHidden = false
    lockImageView.isHidden = false
    bringSubviewToFront(lockedView)
    bringSubviewToFront(lockImageView)
  }

  func lockedImage() -> UIImage? {
    if !hasValidFundingSource {
      return UIImage.imageFromPodBundle("error_backend")?.asTemplate()
    }
    return cardState == .created
      ? UIImage.imageFromPodBundle("icon-card-activate")?.asTemplate()
      : UIImage.imageFromPodBundle("card-locked-icon")?.asTemplate()
  }

  func updateCardNetwork() {
    let enabled = cardState == .active
    if let cardNetwork = cardNetwork {
      self.set(cardNetwork: cardNetwork, enabled: enabled, alpha: 1)
    }
  }
}

private extension AptoPlatformEnvironment {
  func pciEnvironment() -> PCIEnvironment {
    switch self {
    case .production: return .prd
    case .sandbox: return .sbx
    case .staging: return .stg
    case .local: return .stg
    }
  }
}
