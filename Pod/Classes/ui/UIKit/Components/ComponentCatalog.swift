//
//  ComponentCatalog.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/08/2018.
//

import UIKit
import AptoSDK
import PhoneNumberKit

class ComponentCatalog {

  static func amountBigLabelWith(text: String,
                                 textAlignment: NSTextAlignment = .left,
                                 accessibilityLabel: String? = nil,
                                 uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.amountBigFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func amountMediumLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .left,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.amountMediumFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func amountSmallLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .left,
                                   accessibilityLabel: String? = nil,
                                   uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.amountSmallFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func formLabelWith(text: String,
                            textAlignment: NSTextAlignment = .left,
                            multiline: Bool = false,
                            lineSpacing: CGFloat? = nil,
                            letterSpacing: CGFloat? = nil,
                            accessibilityLabel: String? = nil,
                            uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    let textColor = uiConfig.uiTheme == .theme1 ? uiConfig.textPrimaryColor : uiConfig.textSecondaryColor
    if let lineSpacing = lineSpacing {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = textAlignment
      paragraphStyle.lineSpacing = lineSpacing
      var textAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: textColor,
        .font: uiConfig.fontProvider.formLabelFont,
        .paragraphStyle: paragraphStyle
      ]
      if let letterSpacing = letterSpacing {
        textAttributes[.kern] = letterSpacing
      }
      retVal.attributedText = NSAttributedString(string: text, attributes: textAttributes)
    }
    else {
      retVal.text = text
      retVal.font = uiConfig.fontProvider.formLabelFont
      retVal.textColor = textColor
      retVal.textAlignment = textAlignment
    }
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func formListLabelWith(text: String,
                                textAlignment: NSTextAlignment = .left,
                                multiline: Bool = false,
                                accessibilityLabel: String? = nil,
                                uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.formListFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func formFieldWith(placeholder: String,
                            value: String?,
                            accessibilityLabel: String? = nil,
                            uiConfig: UIConfig) -> UITextField {
    let retVal = UITextField()
    retVal.placeholder = placeholder
    retVal.text = value
    retVal.keyboardType = .alphabet
    retVal.autocapitalizationType = .none
    retVal.spellCheckingType = .no
    retVal.autocorrectionType = .no
    retVal.clearsOnInsertion = false
    retVal.clearsOnBeginEditing = false
    retVal.returnKeyType = .next
    retVal.enablesReturnKeyAutomatically = true
    retVal.backgroundColor = .clear
    retVal.font = uiConfig.fontProvider.formFieldFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.accessibilityLabel = accessibilityLabel
    retVal.tintColor = uiConfig.uiPrimaryColor
    return retVal
  }

  static func formEmailTextFieldWith(placeholder: String,
                                     value: String?,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: UIConfig) -> UITextField {
    let retVal = formFieldWith(placeholder: placeholder, value: value, accessibilityLabel: accessibilityLabel, uiConfig: uiConfig)
    retVal.keyboardType = .emailAddress
    retVal.returnKeyType = .done
    retVal.backgroundColor = .white
    retVal.layer.cornerRadius = uiConfig.fieldCornerRadius
    retVal.layer.shadowOffset = CGSize(width: 0, height: 2)
    retVal.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.12).cgColor
    retVal.layer.shadowOpacity = 1
    retVal.layer.shadowRadius = 4
    retVal.leftView = UIView(frame: uiConfig.formFieldInternalPadding)
    retVal.rightView = UIView(frame: uiConfig.formFieldInternalPadding)
    retVal.leftViewMode = .always
    retVal.rightViewMode = .always
    return retVal
  }

  static func formPhoneTextFieldWith(placeholder: String,
                                     value: String?,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: UIConfig) -> PhoneNumberTextField {
    let retVal = PhoneNumberTextField()
    retVal.placeholder = placeholder
    retVal.text = value
    retVal.keyboardType = .phonePad
    retVal.autocapitalizationType = .none
    retVal.spellCheckingType = .no
    retVal.autocorrectionType = .no
    retVal.clearsOnInsertion = false
    retVal.clearsOnBeginEditing = false
    retVal.returnKeyType = .next
    retVal.enablesReturnKeyAutomatically = true
    retVal.backgroundColor = .clear
    retVal.font = uiConfig.fontProvider.formFieldFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.accessibilityLabel = accessibilityLabel
    retVal.tintColor = uiConfig.uiPrimaryColor
    return retVal
  }

  static func formFormattedFieldWith(placeholder: String,
                                     value: String?,
                                     format: String,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: UIConfig) -> UIFormattedTextField {
    let retVal = UIFormattedTextField()
    retVal.placeholder = placeholder
    retVal.formattingPattern = format
    retVal.text = value
    retVal.keyboardType = .alphabet
    retVal.autocapitalizationType = .none
    retVal.spellCheckingType = .no
    retVal.autocorrectionType = .no
    retVal.clearsOnInsertion = false
    retVal.clearsOnBeginEditing = false
    retVal.returnKeyType = .next
    retVal.enablesReturnKeyAutomatically = true
    retVal.backgroundColor = .clear
    retVal.font = uiConfig.fontProvider.formFieldFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.accessibilityLabel = accessibilityLabel
    retVal.tintColor = uiConfig.uiPrimaryColor
    return retVal
  }

  static func formPhoneFieldWith(placeholder: String,
                                 value: InternationalPhoneNumber?,
                                 allowedCountries: [Country],
                                 accessibilityLabel: String? = nil,
                                 uiConfig: UIConfig) -> PhoneTextFieldView {
    switch uiConfig.uiTheme {
    case .theme1:
      return PhoneTextField(allowedCountries: allowedCountries,
                            placeholder: placeholder,
                            value: value,
                            accessibilityLabel: accessibilityLabel,
                            uiConfig: uiConfig)
    case .theme2:
      return PhoneTextFieldTheme2(allowedCountries: allowedCountries,
                                  placeholder: placeholder,
                                  value: value,
                                  accessibilityLabel: accessibilityLabel,
                                  uiConfig: uiConfig)
    }
  }

  static func formTextLinkButtonWith(title: String,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: UIConfig,
                                     tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.backgroundColor = .clear
    button.accessibilityLabel = accessibilityLabel
    var attributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: uiConfig.fontProvider.formTextLink,
      NSAttributedString.Key.foregroundColor: uiConfig.textLinkColor
    ]
    if uiConfig.underlineLinks {
      attributes[NSAttributedString.Key.underlineColor] = uiConfig.textLinkColor
      attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
    }
    let attributedTitle = NSAttributedString(string: title, attributes: attributes)
    button.setAttributedTitle(attributedTitle, for: UIControl.State())
    button.snp.makeConstraints { make in
      make.height.equalTo(50)
    }
    _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  static func anchorLinkButtonWith(title: String,
                                   textAlignment: NSTextAlignment = .center,
                                   accessibilityLabel: String? = nil,
                                   delegate: ContentPresenterViewDelegate? = nil,
                                   uiConfig: UIConfig) -> ContentPresenterView {
    let retVal = ContentPresenterView(uiConfig: uiConfig)
    retVal.textAlignment = textAlignment
    retVal.font = uiConfig.fontProvider.formTextLink
    let textColor = uiConfig.textLinkColor
    retVal.textColor = textColor
    retVal.linkColor = textColor
    retVal.underlineLinks = uiConfig.underlineLinks
    retVal.delegate = delegate
    retVal.set(content: Content.plainText(title))
    return retVal
  }

  static func instructionsLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .center,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.instructionsFont
    switch uiConfig.uiTheme {
    case .theme1:
      retVal.textColor = uiConfig.textTertiaryColor
    case .theme2:
      retVal.textColor = uiConfig.textSecondaryColor
    }
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    retVal.numberOfLines = 0
    return retVal
  }

  static func emptyCaseLabelWith(text: String,
                                 textAlignment: NSTextAlignment = .center,
                                 accessibilityLabel: String? = nil,
                                 uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.textLinkFont
    retVal.textColor = uiConfig.textTertiaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    retVal.numberOfLines = 0
    return retVal
  }

  static func itemDescriptionLabelWith(text: String,
                                       textAlignment: NSTextAlignment = .left,
                                       accessibilityLabel: String? = nil,
                                       uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.itemDescriptionFont
    retVal.textColor = uiConfig.textTertiaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func mainItemLightLabelWith(text: String,
                                     textAlignment: NSTextAlignment = .left,
                                     accessibilityLabel: String? = nil,
                                     uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.mainItemLightFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func mainItemRegularLabelWith(text: String,
                                       textAlignment: NSTextAlignment = .left,
                                       multiline: Bool = false,
                                       accessibilityLabel: String? = nil,
                                       uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.mainItemRegularFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func buttonWith(title: String,
                         showShadow: Bool = true,
                         accessibilityLabel: String? = nil,
                         uiConfig: UIConfig,
                         tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.layer.cornerRadius = uiConfig.buttonCornerRadius
    button.backgroundColor = uiConfig.uiPrimaryColor
    button.accessibilityLabel = accessibilityLabel
    button.titleLabel?.font = uiConfig.fontProvider.primaryCallToActionFont
    button.setTitle(title, for: UIControl.State())
    button.setTitleColor(uiConfig.textButtonColor, for: UIControl.State())
    if showShadow {
      button.layer.shadowOffset = CGSize(width: 0, height: 16)
      button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
      button.layer.shadowOpacity = 1
      button.layer.shadowRadius = 16
    }
    button.snp.makeConstraints { make in
      make.height.equalTo(uiConfig.buttonHeight)
    }
    _ = button.reactive.tap.observeNext(with: tapHandler)
    button.titleLabel?.numberOfLines = 2
    button.titleLabel?.textAlignment = .center
    return button
  }

  static func smallButtonWith(title: String,
                              accessibilityLabel: String? = nil,
                              showShadow: Bool = true,
                              uiConfig: UIConfig,
                              tapHandler: @escaping() -> Void) -> UIButton {
    let button = UIButton()
    button.layer.cornerRadius = uiConfig.smallButtonCornerRadius
    button.backgroundColor = uiConfig.uiPrimaryColor
    button.accessibilityLabel = accessibilityLabel
    button.titleLabel?.font = uiConfig.fontProvider.primaryCallToActionFontSmall
    button.setTitle(title, for: UIControl.State())
    button.setTitleColor(uiConfig.textButtonColor, for: UIControl.State())
    if showShadow {
      button.layer.shadowOffset = CGSize(width: 0, height: 16)
      button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
      button.layer.shadowOpacity = 1
      button.layer.shadowRadius = 16
    }
    button.snp.makeConstraints { make in
      make.height.equalTo(uiConfig.smallButtonHeight)
    }
    _ = button.reactive.tap.observeNext(with: tapHandler)
    return button
  }

  static func sectionTitleLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .left,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.sectionTitleFont
    retVal.textColor = uiConfig.textSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func starredSectionTitleLabelWith(text: String,
                                           textAlignment: NSTextAlignment = .left,
                                           color: UIColor? = nil,
                                           accessibilityLabel: String? = nil,
                                           uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    let textColor = color ?? uiConfig.textTopBarSecondaryColor.withAlphaComponent(0.7)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = textAlignment
    paragraphStyle.lineSpacing = 1.17
    let textAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: textColor,
      .font: uiConfig.fontProvider.starredSectionTitleFont,
      .paragraphStyle: paragraphStyle,
      .kern: 2
    ]
    retVal.attributedText = NSAttributedString(string: text.uppercased(), attributes: textAttributes)
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func boldMessageLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .left,
                                   accessibilityLabel: String? = nil,
                                   multiline: Bool = true,
                                   uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.boldMessageFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func subcurrencyLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .left,
                                   accessibilityLabel: String? = nil,
                                   uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.subCurrencyFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func timestampLabelWith(text: String,
                                 textAlignment: NSTextAlignment = .left,
                                 multiline: Bool = false,
                                 accessibilityLabel: String? = nil,
                                 uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.timestampFont
    retVal.textColor = uiConfig.textTertiaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    retVal.numberOfLines = multiline ? 0 : 1
    return retVal
  }

  static func textLinkLabelWith(text: String,
                                textAlignment: NSTextAlignment = .left,
                                accessibilityLabel: String? = nil,
                                uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.textLinkFont
    retVal.textColor = uiConfig.textLinkColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func topBarAmountLabelWith(text: String,
                                    textAlignment: NSTextAlignment = .center,
                                    accessibilityLabel: String? = nil,
                                    uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.topBarAmountFont
    retVal.textColor = uiConfig.textTopBarSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func topBarTitleLabelWith(text: String,
                                   textAlignment: NSTextAlignment = .center,
                                   accessibilityLabel: String? = nil,
                                   uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.topBarTitleFont
    retVal.textColor = uiConfig.textTopBarSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func topBarTitleBigLabelWith(text: String,
                                      textAlignment: NSTextAlignment = .center,
                                      accessibilityLabel: String? = nil,
                                      uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.topBarTitleBigFont
    retVal.textColor = uiConfig.textTopBarSecondaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    return retVal
  }

  static func largeTitleLabelWith(text: String,
                                  textAlignment: NSTextAlignment = .left,
                                  multiline: Bool = true,
                                  accessibilityLabel: String? = nil,
                                  uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.largeTitleFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func errorTitleLabel(text: String,
                              textAlignment: NSTextAlignment = .center,
                              multiline: Bool = false,
                              accessibilityLabel: String? = nil,
                              uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.errorTitleFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }

  static func errorMessageLabel(text: String,
                                textAlignment: NSTextAlignment = .center,
                                multiline: Bool = true,
                                accessibilityLabel: String? = nil,
                                uiConfig: UIConfig) -> UILabel {
    let retVal = UILabel()
    retVal.text = text
    retVal.font = uiConfig.fontProvider.errorMessageFont
    retVal.textColor = uiConfig.textPrimaryColor
    retVal.textAlignment = textAlignment
    retVal.accessibilityLabel = accessibilityLabel
    if multiline {
      retVal.numberOfLines = 0
    }
    return retVal
  }
}
