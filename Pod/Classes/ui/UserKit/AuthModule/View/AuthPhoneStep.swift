//
//  DataCollectorPhoneStep.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 09/26/17.
//
//

import AptoSDK
import Bond
import ReactiveKit

class AuthPhoneStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  private let disposeBag = DisposeBag()
  private let userData: DataPointList
  private let allowedCountries: [Country]
  let title = "auth.input_phone.title".podLocalized()

  init(userData: DataPointList, allowedCountries: [Country], uiConfig: UIConfig) {
    self.userData = userData
    self.allowedCountries = allowedCountries
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    var retVal: [FormRowView] = []
    let phoneDataPoint = userData.phoneDataPoint
    let phoneField = FormBuilder.phoneTextFieldRow(label: nil,
                                                   allowedCountries: allowedCountries,
                                                   placeholder: "phone-collector.phone.placeholder".podLocalized(),
                                                   value: nil,
                                                   accessibilityLabel: "Phone Number Input Field",
                                                   uiConfig: uiConfig)
    phoneField.bndValue.observeNext { phoneNumber in
      if let countryCode = phoneNumber?.countryCode {
        phoneDataPoint.countryCode.send(countryCode)
      }
      if let formattedPhone = PhoneHelper.sharedHelper().parsePhoneWith(countryCode: phoneNumber?.countryCode,
                                                                        nationalNumber: phoneNumber?.phoneNumber) {
        phoneDataPoint.phoneNumber.send(formattedPhone.phoneNumber.value)
      }
    }.dispose(in: disposeBag)
    retVal.append(phoneField)
    validatableRows.append(phoneField)

    return retVal
  }
}
