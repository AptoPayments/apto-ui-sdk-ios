//
// WaitListView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 05/03/2019.
//

import UIKit
import AptoSDK
import SnapKit

class WaitListView: UIView {
  private let contentView = UIView()
  private let backgroundImageView = UIImageView(frame: .zero)
  private let assetImageView = UIImageView(frame: .zero)
  private let titleLabel: UILabel
  private let mainDescriptionLabel: UILabel
  private let secondaryDescriptionLabel: UILabel
  private let uiConfig: UIConfig
  private let isAssetOptional: Bool

  init(uiConfig: UIConfig, isAssetOptional: Bool = false) {
    self.uiConfig = uiConfig
    self.isAssetOptional = isAssetOptional
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "",
                                                           textAlignment: .center,
                                                           multiline: true,
                                                           uiConfig: uiConfig)
    self.mainDescriptionLabel = ComponentCatalog.formLabelWith(text: "",
                                                               textAlignment: .center,
                                                               multiline: true,
                                                               uiConfig: uiConfig)
    self.secondaryDescriptionLabel = ComponentCatalog.formLabelWith(text: "",
                                                                    textAlignment: .center,
                                                                    multiline: true,
                                                                    uiConfig: uiConfig)
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(title: String) {
    titleLabel.updateAttributedText(title)
  }

  func set(mainDescription: String) {
    mainDescriptionLabel.updateAttributedText(mainDescription)
  }

  func set(secondaryDescription: String) {
    secondaryDescriptionLabel.updateAttributedText(secondaryDescription)
  }

  func set(asset: String?) {
    guard let asset = asset, let url = URL(string: asset) else {
      assetImageView.image = nil
      return
    }
    ImageCache.defaultCache().imageWithUrl(url) { [unowned self] result in
      switch result {
      case .failure(_):
        self.assetImageView.image = nil
      case .success(let image):
        self.assetImageView.image = image
      }
    }
  }

  func set(backgroundImage: String?) {
    guard let backgroundImage = backgroundImage, let url = URL(string: backgroundImage) else {
      backgroundImageView.image = nil
      return
    }
    ImageCache.defaultCache().imageWithUrl(url) { [unowned self] result in
      switch result {
      case .failure(_):
        self.backgroundImageView.image = nil
      case .success(let image):
        self.backgroundImageView.image = image
      }
    }
  }

  func set(backgroundColor: String?) {
    guard let backgroundColor = backgroundColor, let color = UIColor.colorFromHexString(backgroundColor) else {
      self.backgroundColor = uiConfig.uiBackgroundPrimaryColor
      return
    }
    self.backgroundColor = color
  }
}

private extension WaitListView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundPrimaryColor
    setUpBackgroundImageView()
    setUpContentView()
    setUpAssetImageView()
    setUpTitleLabel()
    setUpMainDescriptionLabel()
    setUpSecondaryDescriptionLabel()
  }

  func setUpBackgroundImageView() {
    addSubview(backgroundImageView)
    backgroundImageView.contentMode = .scaleAspectFill
    backgroundImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setUpContentView() {
    contentView.backgroundColor = .clear
    addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }

  func setUpAssetImageView() {
    guard shouldRenderAsset else { return }
    contentView.addSubview(assetImageView)
    assetImageView.contentMode = .scaleAspectFill
    assetImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(184)
      make.width.equalTo(200)
    }
  }

  func setUpTitleLabel() {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      if shouldRenderAsset {
        make.top.equalTo(assetImageView.snp.bottom).offset(24)
      }
      else {
        make.top.equalToSuperview()
      }
      make.left.right.equalToSuperview().inset(titleMargins)
    }
  }

  func setUpMainDescriptionLabel() {
    contentView.addSubview(mainDescriptionLabel)
    mainDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
      make.left.right.equalToSuperview().inset(descriptionMargins)
    }
  }

  func setUpSecondaryDescriptionLabel() {
    contentView.addSubview(secondaryDescriptionLabel)
    secondaryDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(mainDescriptionLabel.snp.bottom).offset(12)
      make.left.right.equalTo(mainDescriptionLabel)
      make.bottom.equalToSuperview()
    }
  }

  var titleMargins: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5, .iPhone678:
      return 16
    default:
      return 48
    }
  }

  var titleOffset: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return shouldRenderAsset ? 20 : -116
    default:
      return 0
    }
  }

  var descriptionMargins: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5, .iPhone678:
      return 16
    default:
      return 40
    }
  }

  var shouldRenderAsset: Bool {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return !isAssetOptional
    default:
      return true
    }
  }
}
