//
// ServerMaintenanceErrorViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 21/12/2018.
//

import AptoSDK
import SnapKit

class ServerMaintenanceErrorViewControllerTheme2: UIViewController {
  private let config: UIConfig?
  private let imageView = UIImageView()
  // swiftlint:disable implicitly_unwrapped_optional
  private var messageLabel: UILabel!
  // swiftlint:enable implicitly_unwrapped_optional
  private let eventHandler: ServerMaintenanceErrorEventHandler

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  init(uiConfig: UIConfig?, eventHandler: ServerMaintenanceErrorEventHandler) {
    self.config = uiConfig
    self.eventHandler = eventHandler

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    eventHandler.viewLoaded()
  }

  @objc private func retry() {
    eventHandler.retryTapped()
  }
}

// MARK: - setup UI
private extension ServerMaintenanceErrorViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = backgroundColor
    setUpImageView()
    setUpMessageLabel()
    setUpRetryButton()
  }

  func setUpImageView() {
    imageView.image = UIImage.imageFromPodBundle("error_maintenance")?.asTemplate()
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
    messageLabel.text = "maintenance.description".podLocalized()
    view.addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(26)
      make.top.equalTo(imageView.snp.bottom).offset(86)
    }
  }

  func setUpRetryButton() {
    let button = UIButton(type: .custom)
    button.setTitle("maintenance.retry.title".podLocalized(), for: .normal)
    button.setTitleColor(tintColor, for: .normal)
    button.backgroundColor = buttonBackgroundColor
    button.layer.cornerRadius = buttonCornerRadius
    button.titleLabel?.font = buttonFont
    view.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(44)
      make.height.equalTo(56)
    }
    button.addTarget(self, action: #selector(self.retry), for: .touchUpInside)
  }

  var backgroundColor: UIColor {
    return config?.uiNavigationSecondaryColor ?? UIColor.colorFromHex(0x202A36)
  }

  var tintColor: UIColor {
    return config?.textTopBarSecondaryColor ?? .white
  }

  var buttonBackgroundColor: UIColor {
    return config?.uiPrimaryColor ?? UIColor.colorFromHex(0x1652F0)
  }

  var titleFont: UIFont {
    return config?.fontProvider.errorMessageFont ?? .systemFont(ofSize: 14, weight: .medium)
  }

  var messageFont: UIFont {
    return config?.fontProvider.errorTitleFont ?? .systemFont(ofSize: 16, weight: .medium)
  }

  var buttonFont: UIFont {
    return config?.fontProvider.primaryCallToActionFont ?? .boldSystemFont(ofSize: 17)
  }

  var buttonCornerRadius: CGFloat {
    return config?.buttonCornerRadius ?? 12
  }
}
