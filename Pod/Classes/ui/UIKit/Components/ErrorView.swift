//
//  ErrorView.swift
//  AptoSDK
//
//  Created by Pau Teruel on 29/05/2019.
//

import UIKit
import AptoSDK
import SnapKit
import ReactiveKit

protocol ErrorViewDelegate: class {
  func linkTapped(url: TappedURL)
}

struct ErrorViewConfiguration {
  let title: String
  let description: String
  let secondaryCTA: String?
  let assetURL: String?
}

class ErrorView: UIView {
  private let assetImageView = UIImageView(frame: .zero)
  private let titleLabel: UILabel
  private let descriptionLabel: UILabel
  private let actionView: ContentPresenterView
  private let uiConfig: UIConfig
  private let isAssetOptional: Bool
  private let centerView = UIView()
  private let disposeBag = DisposeBag()
  private let config: ErrorViewConfiguration
  weak var delegate: ErrorViewDelegate?
  private lazy var assetURL: URL? = {
    guard shouldRenderAsset else { return nil }
    guard let asset = config.assetURL, let url = URL(string: asset) else { return nil }
    return url
  }()

  init(config: ErrorViewConfiguration, uiConfig: UIConfig, isAssetOptional: Bool = true) {
    self.config = config
    self.uiConfig = uiConfig
    self.isAssetOptional = isAssetOptional
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: config.title,
                                                           textAlignment: .center,
                                                           multiline: true,
                                                           uiConfig: uiConfig)
    self.descriptionLabel = ComponentCatalog.formLabelWith(text: config.description,
                                                           textAlignment: .center,
                                                           multiline: true,
                                                           uiConfig: uiConfig)
    self.actionView = ComponentCatalog.anchorLinkButtonWith(title: config.secondaryCTA ?? "", uiConfig: uiConfig)
    super.init(frame: .zero)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ErrorView: ContentPresenterViewDelegate {
  func linkTapped(url: TappedURL) {
    delegate?.linkTapped(url: url)
  }

  // Next methods are intentionally left blank as they do not apply for the current usage
  func showMessage(_ message: String) {
  }

  func show(error: Error) {
  }

  func showLoadingSpinner() {
  }

  func hideLoadingSpinner() {
  }
}

private extension ErrorView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundSecondaryColor
    setupCenterView()
    setUpAssetImageView()
    setUpTitleLabel()
    setUpDescriptionLabel()
    setUpActionView()
  }

  func setupCenterView() {
    addSubview(centerView)
    centerView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(40)
      make.center.equalToSuperview()
    }
  }

  func setUpAssetImageView() {
    guard let url = assetURL else { return }
    ImageCache.defaultCache().imageWithUrl(url) { [unowned self] result in
      switch result {
      case .failure:
        self.assetImageView.image = nil
      case .success(let image):
        self.assetImageView.image = image
      }
    }
    centerView.addSubview(assetImageView)
    assetImageView.contentMode = .scaleAspectFill
    assetImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
      make.width.equalTo(232)
      make.height.equalTo(236)
    }
  }

  func setUpTitleLabel() {
    centerView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      if assetURL != nil {
        make.top.equalTo(assetImageView.snp.bottom).offset(16)
      }
      else {
        make.top.equalToSuperview()
      }
      make.left.right.equalToSuperview().inset(12)
    }
  }

  func setUpDescriptionLabel() {
    centerView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.left.right.equalToSuperview()
    }
  }

  func setUpActionView() {
    actionView.backgroundColor = uiConfig.uiBackgroundSecondaryColor
    actionView.delegate = self
    centerView.addSubview(actionView)
    actionView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(descriptionLabel.snp.bottom).offset(28)
      make.bottom.equalToSuperview()
    }
    actionView.isHidden = config.secondaryCTA == nil
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
