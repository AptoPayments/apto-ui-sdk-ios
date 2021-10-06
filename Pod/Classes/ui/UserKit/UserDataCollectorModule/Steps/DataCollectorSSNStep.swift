//
//  DataCollectorSSNStep.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 22/5/21.
//

import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class SSNStep: DataCollectorBaseStep, DataCollectorStepProtocol {
    var title = "collect_user_data.dob.title".podLocalized()

    private let userData: DataPointList
    private let requiredData: RequiredDataPointList
    private let linkHandler: LinkHandler?
    private let mode: UserDataCollectorFinalStepMode
    private let secondaryCredentialType: DataPointType
    private let allowedDocuments: [Country: [IdDocumentType]]
    private lazy var allowedCountries: [Country] = {
        return Array(allowedDocuments.keys)
    }()
    private var countryField: FormRowCountryPickerView?
    private var documentTypeField: FormRowIdDocumentTypePickerView?
    private var numberField: FormRowTextInputView! // swiftlint:disable:this implicitly_unwrapped_optional

    private var showIdDocument = true
    private var showOptionalIdDocument = false

    private let disposeBag = DisposeBag()
    private var numberTextField: FormRowTextInputView?
    
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
            createCountryPickerField(),
            createDocumentTypePickerField(),
            createNumberField(),
            setUpOptionalIdDocument(),
            FormRowSeparatorView(backgroundColor: UIColor.clear, height: CGFloat(20))
        ].compactMap { return $0 }
    }

    private func calculateFieldsVisibility() {
        // Calculate if the Id Document Fields should be shown
        if let showSSNRequiredDataPoint = requiredData.getRequiredDataPointOf(type: .idDocument) {
            showIdDocument = true
            showOptionalIdDocument = showSSNRequiredDataPoint.optional
        }
        else {
            showIdDocument = false
            showOptionalIdDocument = false
        }
    }

    // MARK: Priate UI methods
    private func createCountryPickerField() -> FormRowCountryPickerView? {
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

    private func createDocumentTypePickerField() -> FormRowIdDocumentTypePickerView? {
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
        documentTypeField.bndValue.observeNext { [weak self] documentType in
            guard let self = self else { return }
            idDocumentDataPoint.documentType.send(documentType)
            guard let numberTextField = self.numberTextField else { return }
            numberTextField.updateValidator(validator: self.validator(for: documentType))
        }.dispose(in: disposeBag)
        self.documentTypeField = documentTypeField
        return documentTypeField
    }

    private func createNumberField() -> FormRowTextInputView? {
        guard showIdDocument == true else { return nil }
        
        let idDocumentDataPoint = userData.idDocumentDataPoint
        let initiallyReadOnly = mode == .updateUser
        let placeholder = "collect_user_data.dob.doc_id.placeholder".podLocalized()
        var label = "collect_user_data.dob.doc_id.title".podLocalized()
        let currentCountry = idDocumentDataPoint.country.value ?? allowedCountries[0]
        if let allowedDocumentTypes = allowedDocuments[currentCountry],
           (allowedCountries.count == 1 && allowedDocumentTypes.count == 1) {
            label.append(" (\(allowedDocumentTypes[0].localizedDescription))")
        }
        numberField = textInputRow(with: idDocumentDataPoint.documentType.value,
                                   label: label,
                                   placeholder: placeholder,
                                   initiallyReadOnly: initiallyReadOnly, uiConfig: uiConfig)
        idDocumentDataPoint.value.bidirectionalBind(to: numberField.bndValue)
        validatableRows.append(numberField)
        numberTextField = numberField
        return numberField
    }

    private func validator(for documentType: IdDocumentType) -> DataValidator<String> {
        switch documentType {
        case .ssn:
            return SSNUSFormatValidator(failReasonMessage: "ssn-collector.id-document.invalid".podLocalized())
        case .identityCard:
            return NonEmptyTextValidator(failReasonMessage: "ssn-collector.id-card.invalid".podLocalized())
        case .passport:
            return NonEmptyTextValidator(failReasonMessage: "ssn-collector.passport.invalid".podLocalized())
        case .driversLicense:
            return NonEmptyTextValidator(failReasonMessage: "ssn-collector.driver-license.invalid".podLocalized())
        }
    }
    
    private func accessibility(for documentType: IdDocumentType?) -> String {
        guard let documentType = documentType else { return "" }
        switch documentType {
        case .ssn:
            return "Id document Input Field"
        case .identityCard:
            return "Identity Card Input Field"
        case .passport:
            return "Passport Input Field"
        case .driversLicense:
            return "Driver license Input Field"
        }
    }

    private func textInputRow(with documentType: IdDocumentType?,
                              label: String,
                              placeholder: String,
                              accessibilityLabel: String? = nil,
                              validator: DataValidator<String>? = nil,
                              initiallyReadonly: Bool = false,
                              firstFormField: Bool = false,
                              lastFormField: Bool = false,
                              initiallyReadOnly: Bool,
                              uiConfig: UIConfig) -> FormRowTextInputView? {
        let accessibilityLabel = accessibility(for: documentType)
        if let documentType = documentType {
            let validator = self.validator(for: documentType)
            return FormBuilder.standardTextInputRowWith(label: label,
                                                               placeholder: placeholder,
                                                               value: "",
                                                               accessibilityLabel: accessibilityLabel,
                                                               validator: validator,
                                                               initiallyReadonly: initiallyReadOnly,
                                                               uiConfig: uiConfig)
        } else {
            return FormBuilder.standardTextInputRowWith(label: label,
                                                               placeholder: placeholder,
                                                               value: "",
                                                               accessibilityLabel: accessibilityLabel,
                                                               initiallyReadonly: initiallyReadOnly,
                                                               uiConfig: uiConfig)
        }
    }
    
    private func setUpOptionalIdDocument() -> FormRowCheckView? {
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
