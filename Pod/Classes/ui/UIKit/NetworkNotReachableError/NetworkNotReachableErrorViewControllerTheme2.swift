//
// NetworkNotReachableErrorViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 21/12/2018.
//

import UIKit
import AptoSDK
import SnapKit

class NetworkNotReachableErrorViewControllerTheme2: UIViewController {
  private let config: UIConfig?
  private let imageView = UIImageView()
  // swiftlint:disable implicitly_unwrapped_optional
  private var messageLabel: UILabel!
  // swiftlint:enable implicitly_unwrapped_optional

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  init(uiConfig: UIConfig?) {
    self.config = uiConfig

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    ServiceLocator.shared.analyticsManager.track(event: Event.noNetwork)
  }
}

// MARK: - setup UI
private extension NetworkNotReachableErrorViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = backgroundColor
    setUpImageView()
    setUpMessageLabel()
    setUpLoadingSpinner()
  }

  func setUpImageView() {
    imageView.image = UIImage.imageFromPodBundle("error_internet", uiTheme: .theme2)?.asTemplate()
    imageView.tintColor = tintColor
    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(view.snp.centerY).offset(-24)
    }
  }

  func setUpMessageLabel() {
    messageLabel = UILabel()
    messageLabel.font = messageFont
    messageLabel.textColor = tintColor
    messageLabel.textAlignment = .center
    messageLabel.numberOfLines = 0
    messageLabel.text = "no_network.description".podLocalized()
    view.addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.top.equalTo(imageView.snp.bottom).offset(86)
    }
  }

  func setUpLoadingSpinner() {
    let label = UILabel()
    label.text = "no_network.reconnect.title".podLocalized()
    label.textColor = retryColor
    label.textAlignment = .center
    label.font = retryFont
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.bottom.equalToSuperview().inset(64)
    }
    let activityIndicatorView = UIActivityIndicatorView(style: .white)
    activityIndicatorView.color = retryColor
    activityIndicatorView.startAnimating()
    view.addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(label.snp.top).offset(-12)
    }
  }

  var backgroundColor: UIColor {
    return config?.uiNavigationSecondaryColor ?? UIColor.colorFromHex(0x202A36)
  }

  var tintColor: UIColor {
    return config?.textTopBarSecondaryColor ?? .white
  }

  var titleFont: UIFont {
    return config?.fontProvider.errorMessageFont ?? .systemFont(ofSize: 14, weight: .medium)
  }

  var messageFont: UIFont {
    return config?.fontProvider.errorTitleFont ?? .systemFont(ofSize: 16, weight: .medium)
  }

  var retryFont: UIFont {
    return config?.fontProvider.errorTitleFont ?? .systemFont(ofSize: 14, weight: .medium)
  }

  var retryColor: UIColor {
    return config?.textTertiaryColor ?? UIColor.colorFromHex(0x8F949A)
  }
}
