//
//  TopBarButtonItem.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 31/12/2018.
//

import UIKit
import AptoSDK

class TopBarButtonItem: UIBarButtonItem {

  private let uiConfig: UIConfig
  private let containerView = UIView()
  private let labelBackground = UIView()
  private let label = UILabel()
  private let text: String
  private let icon: UIImage?
  private let tapHandler: () -> ()
  private var iconView: UIImageView!

  var labelBackgroundColor: UIColor {
    didSet {
      labelBackground.backgroundColor = labelBackgroundColor
    }
  }

  var labelTextColor: UIColor {
    didSet {
      label.textColor = labelTextColor
    }
  }

  override var tintColor: UIColor? {
    didSet {
      iconView.tintColor = tintColor
    }
  }

  init(uiConfig: UIConfig, text: String, icon: UIImage?, tapHandler: @escaping () -> ()) {
    self.uiConfig = uiConfig
    self.text = text
    self.icon = icon?.asTemplate()
    self.tapHandler = tapHandler
    self.labelBackgroundColor = uiConfig.uiPrimaryColor.withAlphaComponent(0.12)
    self.labelTextColor = uiConfig.textTopBarSecondaryColor
    super.init()
    setupUI()
    setupTapHandlers()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) not implemented")
  }

}

private extension TopBarButtonItem {
  func setupUI() {
    setupLabel()
    setupIcon()
    self.customView = containerView
    style = .plain
  }

  func setupLabel() {
    labelBackground.backgroundColor = labelBackgroundColor
    labelBackground.layer.cornerRadius = 10
    labelBackground.clipsToBounds = true
    label.font = labelFont
    label.textColor = labelTextColor
    label.text = text
    labelBackground.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalTo(labelBackground).inset(12)
      make.top.bottom.equalTo(labelBackground).inset(4)
    }
    containerView.addSubview(labelBackground)
    labelBackground.snp.makeConstraints { make in
      make.left.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(1)
    }
  }

  func setupIcon() {
    iconView = UIImageView(image: icon)
    iconView.contentMode = .scaleAspectFit
    iconView.tintColor = labelTextColor
    containerView.addSubview(iconView)
    iconView.snp.makeConstraints { make in
      make.right.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(1)
      make.left.equalTo(labelBackground.snp.right).offset(6)
    }
  }

  var labelFont: UIFont {
    return uiConfig.fontProvider.topBarItemFont
  }
}

private extension TopBarButtonItem {
  func setupTapHandlers() {
    labelBackground.addTapGestureRecognizer { [weak self] in
      self?.tapHandler()
    }
    iconView.addTapGestureRecognizer { [weak self] in
      self?.tapHandler()
    }
  }
}
