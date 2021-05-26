//
//  DataCollectorBirthdaySSNStep.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class BirthdaySSNStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "collect_user_data.dob.title".podLocalized()
  fileprivate let linkHandler: LinkHandler?
  fileprivate let mode: UserDataCollectorFinalStepMode
  fileprivate var birthdayField: FormRowDatePickerView! // swiftlint:disable:this implicitly_unwrapped_optional
  fileprivate var numberField: FormRowTextInputView! // swiftlint:disable:this implicitly_unwrapped_optional
  private var countryField: FormRowCountryPickerView?
  private var documentTypeField: FormRowIdDocumentTypePickerView?

  private let disposeBag = DisposeBag()
  private let userData: DataPointList
  private let requiredData: RequiredDataPointList
  private let secondaryCredentialType: DataPointType
  private var showBirthdate = true
  private var showIdDocument = true
  private var showOptionalIdDocument = false
  private let allowedDocuments: [Country: [IdDocumentType]]
  private lazy var allowedCountries: [Country] = {
    return Array(allowedDocuments.keys)
  }()

  init(requiredData: RequiredDataPointList,
       secondaryCredentialType: DataPointType,
       userData: DataPointList,
       mode: UserDataCollectorFinalStepMode,
       uiConfig: UIConfig,
       linkHandler: LinkHandler?) {
    self.userData = userData
    self.requiredData = requiredData
    self.linkHandler = linkHandler
    self.mode = mode
    self.secondaryCredentialType = secondaryCredentialType
    if let dataPoint = requiredData.getRequiredDataPointOf(type: .idDocument),
       let config = dataPoint.configuration as? AllowedIdDocumentTypesConfiguration,
       !config.allowedDocumentTypes.isEmpty {
      self.allowedDocuments = config.allowedDocumentTypes
    }
    else {
      self.allowedDocuments = [Country.defaultCountry: [IdDocumentType.ssn]]
    }
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    calculateFieldsVisibility()

    return [
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: CGFloat(48)),
      createBirthdayField(),
      createCountryPickerField(),
      createDocumentTypePickerField(),
      createNumberField(),
      setUpOptionalIdDocument(),
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: CGFloat(20))
    ].compactMap { return $0 }
  }

  fileprivate func calculateFieldsVisibility() {
    // Calculate if the Id Document Fields should be shown
    if let showSSNRequiredDataPoint = requiredData.getRequiredDataPointOf(type: .idDocument) {
      showIdDocument = true
      showOptionalIdDocument = showSSNRequiredDataPoint.optional
    }
    else {
      showIdDocument = false
      showOptionalIdDocument = false
    }
    showBirthdate = requiredData.getRequiredDataPointOf(type: .birthDate) != nil
  }
}

private extension BirthdaySSNStep {
  func createBirthdayField() -> FormRowDatePickerView? {
    guard showBirthdate == true else { return nil }

    let birthDateDataPoint = userData.birthDateDataPoint
    let failReason = "issue_card.issue_card.error.dob_too_young".podLocalized()
    let minimumDob = Calendar.current.date(byAdding: .year, value: -18, to: Date())
    let dateValidator = MaximumDateValidator(maximumDate: minimumDob ?? Date(), failReasonMessage: failReason)
    birthdayField = FormBuilder.datePickerRowWith(label: "collect_user_data.dob.dob.title".podLocalized(),
                                                  placeholder: "collect_user_data.dob.dob.placeholder".podLocalized(),
                                                  format: .dateOnly,
                                                  value: birthDateDataPoint.date.value,
                                                  accessibilityLabel: "Birthdate Input Field",
                                                  validator: dateValidator,
                                                  firstFormField: true,
                                                  uiConfig: uiConfig)
    birthDateDataPoint.date.bidirectionalBind(to: birthdayField.bndDate).dispose(in: disposeBag)
    validatableRows.append(birthdayField)
    return birthdayField
  }

  func createCountryPickerField() -> FormRowCountryPickerView? {
    guard showIdDocument == true else { return nil }

    let idDocumentDataPoint = userData.idDocumentDataPoint
    guard allowedCountries.count > 1 else {
      idDocumentDataPoint.country.send(allowedCountries.first)
      return nil
    }

    let countryField = FormBuilder.countryPickerRow(label: "collect_user_data.dob.doc_country.title".podLocalized(),
                                                    allowedCountries: allowedCountries,
                                                    uiConfig: uiConfig)
    countryField.bndValue.observeNext { [unowned self] country in
      idDocumentDataPoint.country.send(country)
      guard let allowedDocumentTypes = self.allowedDocuments[country] else {
        fatalError("No document types configured for country \(country.name)")
      }
      self.documentTypeField?.allowedDocumentTypes = allowedDocumentTypes
    }.dispose(in: disposeBag)
    self.countryField = countryField
    return countryField
  }

  func createDocumentTypePickerField() -> FormRowIdDocumentTypePickerView? {
    guard showIdDocument == true else { return nil }

    let idDocumentDataPoint = userData.idDocumentDataPoint
    let currentCountry = idDocumentDataPoint.country.value ?? allowedCountries[0]
    guard let allowedDocumentTypes = allowedDocuments[currentCountry],
          !allowedDocuments.isEmpty else {
      fatalError("No document types configured for country \(currentCountry.name)")
    }
    guard allowedCountries.count > 1 || allowedDocumentTypes.count > 1 else {
      idDocumentDataPoint.documentType.send(allowedDocumentTypes[0])
      return nil
    }
    let label = "collect_user_data.dob.doc_type.title".podLocalized()
    let documentTypeField = FormBuilder.idDocumentTypePickerRow(label: label,
                                                                allowedDocumentTypes: allowedDocumentTypes,
                                                                uiConfig: uiConfig)
    documentTypeField.bndValue.observeNext { documentType in
      idDocumentDataPoint.documentType.send(documentType)
    }.dispose(in: disposeBag)
    self.documentTypeField = documentTypeField
    return documentTypeField
  }

  func createNumberField() -> FormRowTextInputView? {
    guard showIdDocument == true else { return nil }

    let idDocumentDataPoint = userData.idDocumentDataPoint
    let initiallyReadOnly = mode == .updateUser
    let validator = SSNUSFormatValidator(failReasonMessage: "birthday-collector.id-document.invalid".podLocalized())
    let placeholder = "collect_user_data.dob.doc_id.placeholder".podLocalized()
    var label = "collect_user_data.dob.doc_id.title".podLocalized()
    let currentCountry = idDocumentDataPoint.country.value ?? allowedCountries[0]
    if let allowedDocumentTypes = allowedDocuments[currentCountry],
       (allowedCountries.count == 1 && allowedDocumentTypes.count == 1) {
      label.append(" (\(allowedDocumentTypes[0].localizedDescription))")
    }
    numberField = FormBuilder.standardTextInputRowWith(label: label,
                                                       placeholder: placeholder,
                                                       value: "",
                                                       accessibilityLabel: "Id document Input Field",
                                                       validator: validator,
                                                       initiallyReadonly: initiallyReadOnly,
                                                       uiConfig: uiConfig)
    idDocumentDataPoint.value.bidirectionalBind(to: numberField.bndValue)
    validatableRows.append(numberField)

    return numberField
  }

  func setUpOptionalIdDocument() -> FormRowCheckView? {
    guard showOptionalIdDocument == true else { return nil }
    let idDocumentDataPoint = userData.idDocumentDataPoint
    let text = "collect_user_data.dob.doc_id.not-specified.title".podLocalized()
    let label = ComponentCatalog.formListLabelWith(text: text,
                                                   uiConfig: uiConfig)
    let documentNotSpecified = FormRowCheckView(label: label, height: 20)
    documentNotSpecified.checkIcon.tintColor = uiConfig.uiPrimaryColor
    rows.append(documentNotSpecified)
    if let notSpecified = idDocumentDataPoint.notSpecified {
      documentNotSpecified.bndValue.send(notSpecified)
      numberField.bndValue.send(nil)
      self.validatableRows = self.validatableRows.compactMap { ($0 == self.numberField) ? nil : $0 }
      self.setupStepValidation()
    }
    documentNotSpecified.bndValue.observeNext { checked in
      idDocumentDataPoint.notSpecified = checked
      idDocumentDataPoint.country.send(nil)
      idDocumentDataPoint.value.send(nil)
      idDocumentDataPoint.documentType.send(nil)
      self.numberField.isEnabled = !checked
      self.countryField?.isEnabled = !checked
      self.documentTypeField?.isEnabled = !checked
      if checked {
        self.numberField.bndValue.send(nil)
        self.validatableRows = self.validatableRows.compactMap {
          ($0 == self.numberField || $0 == self.countryField || $0 == self.documentTypeField) ? nil : $0
        }
      }
      else {
        self.validatableRows.append(self.numberField)
        if let countryField = self.countryField {
          self.validatableRows.append(countryField)
        }
        if let documentTypeField = self.documentTypeField {
          self.validatableRows.append(documentTypeField)
        }
      }
      self.setupStepValidation()
    }.dispose(in: disposeBag)
    return documentNotSpecified
  }
}
