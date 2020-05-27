//
//  FormBuilder.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/08/16.
//

import Foundation
import AptoSDK
import TTTAttributedLabel
import Bond
import ReactiveKit

// swiftlint:disable type_body_length
class FormBuilder {

  static func sectionTitleRowWith(text: String,
                                  textAlignment: NSTextAlignment = .left,
                                  position: PositionInRow = .bottom,
                                  height: CGFloat = 60,
                                  uiConfig: UIConfig) -> FormRowLabelView {
    let defaultLabel = ComponentCatalog.sectionTitleLabelWith(text: text,
                                                              textAlignment: textAlignment,
                                                              uiConfig: uiConfig)
    defaultLabel.snp.makeConstraints { make in
      make.height.equalTo(26)
    }
    let retVal = FormRowLabelView(label: defaultLabel, showSplitter: false, height: height, position: position)
    retVal.padding = uiConfig.formRowPadding
    return retVal
  }

  static func mainItemRegularRowWith(text: String,
                                     textAlignment: NSTextAlignment = .center,
                                     position: PositionInRow = .center,
                                     multiLine: Bool = false,
                                     uiConfig: UIConfig) -> FormRowLabelView {
    let label = ComponentCatalog.mainItemRegularLabelWith(text: text,
                                                          textAlignment: textAlignment,
                                                          accessibilityLabel: nil,
                                                          uiConfig: uiConfig)
    if multiLine {
      label.numberOfLines = 0
    }
    return FormRowLabelView(label: label, showSplitter: false, position: position)
  }

  static func itemDescriptionRowWith(text: String,
                                     textAlignment: NSTextAlignment = .center,
                                     position: PositionInRow = .center,
                                     uiConfig: UIConfig) -> FormRowLabelView {
    let noteLabel = ComponentCatalog.itemDescriptionLabelWith(text: text,
                                                              textAlignment: textAlignment,
                                                              accessibilityLabel: nil,
                                                              uiConfig: uiConfig)
    return FormRowLabelView(label: noteLabel, showSplitter: false, position: position)
  }

  static func richTextNoteRowWith(text: NSAttributedString,
                                  textAlignment: NSTextAlignment = .center,
                                  position: PositionInRow = .center,
                                  multiline: Bool = false,
                                  uiConfig: UIConfig,
                                  linkHandler: LinkHandler?) -> FormRowRichTextLabelView {
    let attributedLabel = TTTAttributedLabel(frame: CGRect.zero)
    attributedLabel.linkAttributes = [
      NSAttributedString.Key.foregroundColor: uiConfig.textLinkColor,
      NSAttributedString.Key.font: uiConfig.fontProvider.formTextLink
    ]
    if uiConfig.underlineLinks {
      attributedLabel.linkAttributes[NSAttributedString.Key.underlineColor] = uiConfig.textLinkColor
      attributedLabel.linkAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
    }
    let label = FormRowRichTextLabelView(label: attributedLabel,
                                         showSplitter: false,
                                         position: position,
                                         linkHandler: linkHandler)
    if multiline {
      attributedLabel.numberOfLines = 0
    }
    attributedLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes
    attributedLabel.setText(text)
    label.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    label.label.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    label.padding = uiConfig.formRowPadding
    return label
  }

  static func instructionsRowWith(text: String,
                                  textAlignment: NSTextAlignment = .center,
                                  position: PositionInRow = .center,
                                  uiConfig: UIConfig) -> FormRowLabelView {
    let multilineLabel = ComponentCatalog.instructionsLabelWith(text: text,
                                                                textAlignment: textAlignment,
                                                                accessibilityLabel: nil,
                                                                uiConfig: uiConfig)
    return FormRowLabelView(label: multilineLabel, showSplitter: false, position: position)
  }

  static func standardTextInputRowWith(label: String,
                                       placeholder: String,
                                       value: String?,
                                       accessibilityLabel: String? = nil,
                                       validator: DataValidator<String>? = nil,
                                       initiallyReadonly: Bool = false,
                                       firstFormField: Bool = false,
                                       lastFormField: Bool = false,
                                       uiConfig: UIConfig) -> FormRowTextInputView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: value,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowTextInputView(label: uiLabel,
                                      labelWidth: nil,
                                      textField: textField,
                                      initiallyReadOnly: initiallyReadonly,
                                      firstFormField: firstFormField,
                                      lastFormField: lastFormField,
                                      validator: validator,
                                      uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    retVal.showSplitter = false
    return retVal
  }

  // swiftlint:disable function_parameter_count
  static func addressInputRowWith(label: String,
                                  placeholder: String,
                                  value: String?,
                                  accessibilityLabel: String? = nil,
                                  addressManager: AddressManager,
                                  allowedCountries: [Country],
                                  uiConfig: UIConfig) -> FormRowAddressView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: value,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowAddressView(label: uiLabel,
                                    textField: textField,
                                    addressManager: addressManager,
                                    allowedCountries: allowedCountries,
                                    uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    retVal.showSplitter = false
    return retVal
  }

  static func formattedTextInputRowWith(label: String,
                                        placeholder: String,
                                        format: String,
                                        keyboardType: UIKeyboardType,
                                        value: String?,
                                        accessibilityLabel: String? = nil,
                                        validator: DataValidator<String>? = nil,
                                        hiddenText: Bool = false,
                                        initiallyReadOnly: Bool = false,
                                        firstFormField: Bool = false,
                                        lastFormField: Bool = false,
                                        uiConfig: UIConfig) -> FormRowTextInputView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFormattedFieldWith(placeholder: placeholder,
                                                            value: value,
                                                            format: format,
                                                            accessibilityLabel: accessibilityLabel,
                                                            uiConfig: uiConfig)
    textField.isSecureTextEntry = hiddenText
    let retVal = FormRowTextInputView(label: uiLabel,
                                      labelWidth: nil,
                                      textField: textField,
                                      toggleSecureEntryState: hiddenText,
                                      initiallyReadOnly: initiallyReadOnly,
                                      firstFormField: firstFormField,
                                      lastFormField: lastFormField,
                                      validator: validator,
                                      uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.defaultTextColor
    retVal.focusedColor = uiConfig.defaultTextColor
    retVal.showSplitter = false
    return retVal
  }
  // swiftlint:enable function_parameter_count

  static func datePickerRowWith(label: String?,
                                placeholder: String,
                                format: FormDateFormat,
                                value: Date?,
                                accessibilityLabel: String? = nil,
                                validator: DataValidator<Date>? = nil,
                                firstFormField: Bool = false,
                                lastFormField: Bool = false,
                                uiConfig: UIConfig) -> FormRowDatePickerView {
    var uiLabel: UILabel?
    if let label = label {
      uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    }
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: nil,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowDatePickerView(label: uiLabel,
                                       labelWidth: nil,
                                       textField: textField,
                                       date: value,
                                       format: format,
                                       firstFormField: firstFormField,
                                       lastFormField: lastFormField,
                                       validator: validator,
                                       uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    retVal.padding = uiConfig.formRowPadding
    retVal.backgroundColor = uiConfig.uiBackgroundSecondaryColor
    retVal.layer.cornerRadius = uiConfig.fieldCornerRadius
    retVal.layer.shadowOffset = CGSize(width: 0, height: 2)
    retVal.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
    retVal.layer.shadowOpacity = 1
    retVal.layer.shadowRadius = 4
    retVal.textField.textAlignment = .center
    retVal.textField.snp.updateConstraints { make in
      make.height.equalTo(uiConfig.formRowHeight)
    }
    return retVal
  }

  static func valuePickerRowWith(label: String,
                                 placeholder: String,
                                 labelWidth: CGFloat? = nil,
                                 value: String?,
                                 values: [FormValuePickerValue],
                                 accessibilityLabel: String? = nil,
                                 validator: DataValidator<String>? = nil,
                                 uiConfig: UIConfig) -> FormRowValuePickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: placeholder,
                                                   value: value,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowValuePickerView(label: uiLabel,
                                        labelWidth: labelWidth,
                                        textField: textField,
                                        value: value,
                                        values: values,
                                        validator: validator,
                                        uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.defaultTextColor
    retVal.focusedColor = uiConfig.defaultTextColor
    retVal.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    return retVal
  }

  static func emailRowWith(label: String?,
                           placeholder: String,
                           value: String?,
                           accessibilityLabel: String? = nil,
                           failReasonMessage: String,
                           uiConfig: UIConfig) -> FormRowEmailView {
    var uiLabel: UILabel?
    if let label = label {
      uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    }
    let textField = ComponentCatalog.formEmailTextFieldWith(placeholder: placeholder,
                                                            value: value,
                                                            accessibilityLabel: accessibilityLabel,
                                                            uiConfig: uiConfig)
    let retVal = FormRowEmailView(label: uiLabel,
                                  labelWidth: nil,
                                  textField: textField,
                                  failReasonMessage: failReasonMessage,
                                  uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    retVal.padding = uiConfig.formRowPadding
    return retVal
  }

  static func phoneTextFieldRow(label: String?,
                                allowedCountries: [Country],
                                placeholder: String,
                                value: InternationalPhoneNumber?,
                                accessibilityLabel: String? = nil,
                                uiConfig: UIConfig) -> FormRowPhoneFieldView {
    var uiLabel: UILabel?
    if let label = label {
      uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    }
    let phoneField = ComponentCatalog.formPhoneFieldWith(placeholder: placeholder,
                                                         value: value,
                                                         allowedCountries: allowedCountries,
                                                         accessibilityLabel: accessibilityLabel,
                                                         uiConfig: uiConfig)
    let retVal = FormRowPhoneFieldView(label: uiLabel, phoneTextField: phoneField, height: uiConfig.formRowHeight)
    retVal.padding = uiConfig.formRowPadding
    return retVal
  }

  static func countryPickerRow(label: String,
                               allowedCountries: [Country],
                               value: Country? = nil,
                               accessibilityLabel: String? = nil,
                               uiConfig: UIConfig) -> FormRowCountryPickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: "",
                                                   value: nil,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    return FormRowCountryPickerView(label: uiLabel,
                                    textField: textField,
                                    allowedCountries: allowedCountries,
                                    value: value,
                                    uiConfig: uiConfig)
  }

  static func idDocumentTypePickerRow(label: String,
                                      allowedDocumentTypes: [IdDocumentType],
                                      value: IdDocumentType? = nil,
                                      accessibilityLabel: String? = nil,
                                      uiConfig: UIConfig) -> FormRowIdDocumentTypePickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: "",
                                                   value: nil,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    return FormRowIdDocumentTypePickerView(label: uiLabel,
                                           textField: textField,
                                           allowedDocumentTypes: allowedDocumentTypes,
                                           value: value,
                                           uiConfig: uiConfig)
  }

  static func buttonRowWith(title: String,
                            accessibilityLabel: String? = nil,
                            tapHandler: @escaping() -> Void,
                            uiConfig: UIConfig) -> FormRowButtonView {
    let button = ComponentCatalog.buttonWith(title: title,
                                             accessibilityLabel: accessibilityLabel,
                                             uiConfig: uiConfig,
                                             tapHandler: tapHandler)
    let retVal = FormRowButtonView(button: button)
    return retVal
  }

  static func textButtonRowWith(title: String,
                                accessibilityLabel: String? = nil,
                                tapHandler: @escaping() -> Void,
                                uiConfig: UIConfig) -> FormRowButtonView {
    let button = ComponentCatalog.formTextLinkButtonWith(title: title,
                                                         accessibilityLabel: accessibilityLabel,
                                                         uiConfig: uiConfig,
                                                         tapHandler: tapHandler)
    let retVal = FormRowButtonView(button: button)
    return retVal
  }

  static func linkRowWith(title: String,
                          leftIcon: UIImage?,
                          leftIconMargin: CGFloat = 36,
                          showRightIcon: Bool = false,
                          showSplitter: Bool = false,
                          height: CGFloat = 44,
                          uiConfig: UIConfig,
                          clickHandler: @escaping (() -> Void)) -> FormRowLinkView {
    let label = ComponentCatalog.textLinkLabelWith(text: title, uiConfig: uiConfig)
    var uiImageView: UIImageView?
    if let leftIcon = leftIcon {
      uiImageView = UIImageView(image: leftIcon)
      uiImageView?.tintColor = uiConfig.uiPrimaryColor
    }
    let retVal = FormRowLinkView(label: label,
                                 leftIcon: uiImageView,
                                 leftIconMargin: leftIconMargin,
                                 shadowedLabel: nil,
                                 showSplitter: false,
                                 showRightIcon: false,
                                 height: height,
                                 clickHandler: clickHandler)
    return retVal
  }

  static func secondaryLinkRowWith(title: String,
                                   leftIcon: UIImage?,
                                   leftIconMargin: CGFloat = 0,
                                   showRightIcon: Bool = false,
                                   showSplitter: Bool = false,
                                   height: CGFloat = 44,
                                   uiConfig: UIConfig,
                                   clickHandler: @escaping (() -> Void)) -> FormRowLinkView {
    let label = ComponentCatalog.mainItemLightLabelWith(text: title, uiConfig: uiConfig)
    label.textColor = uiConfig.textPrimaryColorDisabled
    var uiImageView: UIImageView?
    if let leftIcon = leftIcon {
      uiImageView = UIImageView(image: leftIcon)
      uiImageView?.tintColor = uiConfig.uiPrimaryColorDisabled
    }
    let retVal = FormRowLinkView(label: label,
                                 leftIcon: uiImageView,
                                 leftIconMargin: leftIconMargin,
                                 shadowedLabel: nil,
                                 showSplitter: false,
                                 showRightIcon: false,
                                 height: height,
                                 clickHandler: clickHandler)
    return retVal
  }

  static func linkRowWith(title: String,
                          subtitle: String,
                          leftIcon: UIImage?,
                          height: CGFloat = 66,
                          showSplitter: Bool = true,
                          showAccessoryView: Bool = true,
                          uiConfig: UIConfig,
                          clickHandler: @escaping (() -> Void)) -> FormRowView {
    let titleLabel = ComponentCatalog.mainItemLightLabelWith(text: title, uiConfig: uiConfig)
    let subtitleLabel = ComponentCatalog.itemDescriptionLabelWith(text: subtitle, uiConfig: uiConfig)
    let imageView: UIImageView?
    if let leftIcon = leftIcon {
      imageView = UIImageView(image: leftIcon)
      imageView?.tintColor = uiConfig.uiPrimaryColor
    }
    else {
      imageView = nil
    }
    let rightView =
      showAccessoryView ? UIImageView(image: UIImage.imageFromPodBundle("row_arrow")?.asTemplate()) : nil
    rightView?.tintColor = uiConfig.uiTertiaryColor
    rightView?.snp.makeConstraints { make in
      make.width.equalTo(7)
      make.height.equalTo(12)
    }
    return FormRowTopBottomLabelViewTheme2(titleLabel: titleLabel,
                                           subtitleLabel: subtitle.isEmpty ? nil : subtitleLabel,
                                           leftImageView: imageView,
                                           rightView: rightView,
                                           height: height,
                                           showSplitter: showSplitter,
                                           clickHandler: clickHandler)
  }

  static func checkboxRowWith(text: String,
                              uiConfig: UIConfig) -> FormRowCheckView {
    let checkboxLabel = ComponentCatalog.formLabelWith(text: text, uiConfig: uiConfig)
    return FormRowCheckView(label: checkboxLabel, height: 20)
  }

  static func radioRowWith(labels: [String],
                           values: [Int],
                           leftIcons: [UIImage?]? = [],
                           uiConfig: UIConfig) -> FormRowRadioView {
    let creditLabels: [UILabel] = labels.map { label -> UILabel in
      let uiLabel = ComponentCatalog.formLabelWith(text: label, uiConfig: uiConfig)
      uiLabel.font = uiConfig.fontProvider.formFieldFont
      uiLabel.textColor = uiConfig.textSecondaryColor
      return uiLabel
    }
    let retVal = FormRowRadioView(labels: creditLabels,
                                  values: values,
                                  leftIcons: leftIcons,
                                  onImage: nil,
                                  flashColor: uiConfig.iconPrimaryColor)
    retVal.tickImageView?.tintColor = uiConfig.iconPrimaryColor
    retVal.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    return retVal
  }

  static func balanceRadioRowWith(balances: [FormRowBalanceRadioViewValue],
                                  values: [Int],
                                  uiConfig: UIConfig) -> FormRowBalanceRadioViewProtocol {
    let retVal = FormRowBalanceRadioViewTheme2(items: balances,
                                               values: values,
                                               flashColor: uiConfig.uiPrimaryColor,
                                               uiConfig: uiConfig)
    retVal.tickImageView.tintColor = uiConfig.uiPrimaryColor
    retVal.backgroundColor = uiConfig.uiBackgroundSecondaryColor
    return retVal
  }

  static func valuePickerRow(title: String,
                             selectedValue: String? = nil,
                             values: [FormValuePickerValue],
                             placeholder: String,
                             accessibilityLabel: String? = nil,
                             validator: DataValidator<String>? = nil,
                             uiConfig: UIConfig) -> FormRowValuePickerView {
    let uiLabel = ComponentCatalog.formLabelWith(text: title, uiConfig: uiConfig)
    let textField = ComponentCatalog.formFieldWith(placeholder: "",
                                                   value: selectedValue,
                                                   accessibilityLabel: accessibilityLabel,
                                                   uiConfig: uiConfig)
    let retVal = FormRowValuePickerView(label: uiLabel,
                                        labelWidth: nil,
                                        textField: textField,
                                        value: selectedValue,
                                        values: values,
                                        validator: validator,
                                        uiConfig: uiConfig)
    retVal.unfocusedColor = uiConfig.textPrimaryColor
    retVal.focusedColor = uiConfig.textPrimaryColor
    retVal.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    retVal.showSplitter = false
    return retVal
  }

  static func sliderRowWith(text: String,
                            minimumValue: Int,
                            maximumValue: Int,
                            textPattern: String,
                            validator: DataValidator<Int>? = nil,
                            accessibilityLabel: String? = nil,
                            uiConfig: UIConfig) -> FormRowNumericSliderView {
    let uiLabel = ComponentCatalog.amountBigLabelWith(text: text,
                                                      uiConfig: uiConfig)
    return FormRowNumericSliderView(valueLabel: uiLabel,
                                    minimumValue: minimumValue,
                                    maximumValue: maximumValue,
                                    textPattern: textPattern,
                                    validator: validator,
                                    accessibilityLabel: accessibilityLabel,
                                    uiConfig: uiConfig)
  }

  static func radioButtonRowWith(title: String,
                                 tapHandler: @escaping() -> Void,
                                 uiConfig: UIConfig) -> FormRowButtonView {
    let button = ComponentCatalog.formTextLinkButtonWith(title: title, uiConfig: uiConfig, tapHandler: tapHandler)
    let retVal = FormRowButtonView(button: button)
    return retVal
  }

  static func labelSwitchRowWith(title: String,
                                 labelWidth: CGFloat,
                                 showSplitter: Bool = true,
                                 height: CGFloat = 44,
                                 onChange: ((UISwitch) -> Void)? = nil,
                                 uiConfig: UIConfig) -> FormRowSwitchView {
    let label = ComponentCatalog.formLabelWith(text: title, uiConfig: uiConfig)
    let switcher = UISwitch()
    if let onChange = onChange {
      switcher.setOnChnageListener(action: onChange)
    }
    switcher.onTintColor = uiConfig.uiPrimaryColor
    let retVal = FormRowSwitchView(label: label,
                                   labelWidth: labelWidth,
                                   switcher: switcher,
                                   showSplitter: showSplitter,
                                   height: height)
    return retVal
  }

  static func titleSubtitleSwitchRowWith(title: String,
                                         subtitle: String,
                                         height: CGFloat = 66,
                                         leftMargin: CGFloat = 0,
                                         uiConfig: UIConfig,
                                         onChange: ((UISwitch) -> Void)? = nil) -> FormRowSwitchTitleSubtitleView {
    let titleLabel = ComponentCatalog.mainItemLightLabelWith(text: title, uiConfig: uiConfig)
    let subtitleLabel = ComponentCatalog.itemDescriptionLabelWith(text: subtitle, uiConfig: uiConfig)
    let switcher = UISwitch()
    if let onChange = onChange {
      switcher.setOnChnageListener(action: onChange)
    }
    switcher.onTintColor = uiConfig.uiPrimaryColor
    return FormRowSwitchTitleSubtitleView(titleLabel: titleLabel,
                                          subtitleLabel: subtitleLabel,
                                          switcher: switcher,
                                          height: height,
                                          leftMargin: leftMargin)
  }

  static func labelLabelRowWith(leftText: String,
                                rightText: String?,
                                labelWidth: CGFloat? = 120,
                                textAlignment: NSTextAlignment = .right,
                                showSplitter: Bool = true,
                                backgroundColor: UIColor? = nil,
                                uiConfig: UIConfig) -> FormRowLeftRightLabelView {
    let rightLabel = ComponentCatalog.mainItemLightLabelWith(text: rightText ?? "",
                                                             textAlignment: .right,
                                                             uiConfig: uiConfig)
    rightLabel.textColor = uiConfig.textSecondaryColor
    let retVal = FormRowLeftRightLabelView(
      label: ComponentCatalog.mainItemRegularLabelWith(text: leftText, uiConfig: uiConfig),
      rightLabel: rightLabel,
      labelWidth: labelWidth,
      showSplitter: showSplitter
    )
    guard let color = backgroundColor else {
      return retVal
    }
    retVal.backgroundColor = color
    retVal.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
    return retVal
  }

  static func imageLabelRowWith(imageView: UIImageView?,
                                rightText: String?,
                                textAlignment: NSTextAlignment = .right,
                                multiLine: Bool = false,
                                showSplitter: Bool = false,
                                height: CGFloat = 40,
                                uiConfig: UIConfig) -> FormRowLeftImageRightLabelView {
    let rightLabel = ComponentCatalog.mainItemLightLabelWith(text: rightText ?? "",
                                                             textAlignment: textAlignment,
                                                             uiConfig: uiConfig)
    if multiLine {
      rightLabel.numberOfLines = 0
    }
    return FormRowLeftImageRightLabelView(imageView: imageView,
                                          rightLabel: rightLabel,
                                          showSplitter: showSplitter,
                                          height: height)
  }

  static func separatorRow(height: CGFloat) -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: .clear, height: height, showTopLine: false, showBottomLine: false)
  }

  static func topSeparatorRow() -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: .clear, height: 1, showTopLine: false, showBottomLine: true)
  }

  static func bottomSeparatorRow() -> FormRowSeparatorView {
    return FormRowSeparatorView(backgroundColor: .clear, height: 1, showTopLine: true, showBottomLine: false)
  }

  static func formLabelRowWith(text: String, uiConfig: UIConfig) -> FormRowLabelView {
    let label = ComponentCatalog.formLabelWith(text: text, uiConfig: uiConfig)
    return FormRowLabelView(label: label, showSplitter: false, height: 40, position: .bottom)
  }

  static func formAnswerRowWith(text: String,
                                height: CGFloat = 40,
                                uiConfig: UIConfig) -> FormRowMultilineLabelView {
    let label = UILabel()
    label.text = text
    label.textColor = uiConfig.textPrimaryColor
    label.font = uiConfig.fontProvider.formFieldFont
    label.numberOfLines = 0
    label.textAlignment = .left
    let retVal = FormRowMultilineLabelView(label: label, height: height)
    retVal.padding = uiConfig.formRowPadding
    return retVal
  }
}
// swiftlint:enable type_body_length
