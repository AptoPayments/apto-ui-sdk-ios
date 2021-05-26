//
//  DataCollectorAddressStep.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import AptoSDK
import Bond
import ReactiveKit

class AddressStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "collect_user_data.address.title".podLocalized()
  private let disposeBag = DisposeBag()
  private let requiredData: RequiredDataPointList
  private let userData: DataPointList
  private let address: Address
  private let allowedCountries: [Country]
  private let addressManager: AddressManager
  private var aptUnitField: FormRowTextInputView?

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       uiConfig: UIConfig,
       googleGeocodingApiKey: String?) {
    self.requiredData = requiredData
    self.userData = userData
    self.address = userData.addressDataPoint
    self.addressManager = AddressManager(apiKey: googleGeocodingApiKey)
    if let country = userData.currentCountry() {
      self.allowedCountries = [country]
    }
    else if let dateDataPoint = requiredData.getRequiredDataPointOf(type: .address),
            let config = dateDataPoint.configuration as? AllowedCountriesConfiguration,
            !config.allowedCountries.isEmpty {
      self.allowedCountries = config.allowedCountries
    }
    else {
      self.allowedCountries = [Country.defaultCountry]
    }
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    return [
      FormBuilder.separatorRow(height: 32),
      createAddressField(),
        FormBuilder.separatorRow(height: 12),
      createAptUnitField()
    ]
  }

  private func createAddressField() -> FormRowAddressView {
    let placeholder = "collect_user_data.address.address.placeholder".podLocalized()
    let validator = ZipCodeNotEmptyValidator(failReasonMessage: "address-collector.zipcode.empty")
    let addressField = FormBuilder.addressInputRowWith(label: "collect_user_data.address.address.title".podLocalized(),
                                                       placeholder: placeholder,
                                                       value: "",
                                                       accessibilityLabel: "Address Input Field",
                                                       addressManager: addressManager,
                                                       allowedCountries: allowedCountries,
                                                       validator: validator,
                                                       uiConfig: uiConfig)
    addressField.address.observeNext { [unowned self] address in
      self.address.address.send(address?.address.value)
      self.address.apUnit.send(address?.apUnit.value)
      self.address.country.send(address?.country.value)
      self.address.city.send(address?.city.value)
      self.address.region.send(address?.region.value)
      self.address.zip.send(address?.zip.value)
    }.dispose(in: disposeBag)
    validatableRows.append(addressField)
    return addressField
  }

  private func createAptUnitField() -> FormRowTextInputView {
    let label = "collect_user_data.address.apt_unit.title".podLocalized()
    let placeholder = "collect_user_data.address.apt_unit.placeholder".podLocalized()
    let aptUnitField = FormBuilder.standardTextInputRowWith(label: label,
                                                            placeholder: placeholder,
                                                            value: "",
                                                            uiConfig: uiConfig)
    address.apUnit.bidirectionalBind(to: aptUnitField.bndValue)
    self.aptUnitField = aptUnitField
    aptUnitField.isHidden = true
    return aptUnitField
  }
}
