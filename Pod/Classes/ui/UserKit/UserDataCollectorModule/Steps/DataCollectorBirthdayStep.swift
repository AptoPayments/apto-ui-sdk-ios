//
//  DataCollectorBirthdayStep.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 06/03/16.
//
//

import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class BirthdayStep: DataCollectorBaseStep, DataCollectorStepProtocol {
  var title = "collect_user_data.dob.title".podLocalized()
  fileprivate let linkHandler: LinkHandler?
  fileprivate let mode: UserDataCollectorFinalStepMode
  fileprivate var birthdayField: FormRowDatePickerView! // swiftlint:disable:this implicitly_unwrapped_optional

  private let disposeBag = DisposeBag()
  private let userData: DataPointList
  private let requiredData: RequiredDataPointList
  private let secondaryCredentialType: DataPointType
  private var showBirthdate = true

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
    super.init(uiConfig: uiConfig)
  }

  override func setupRows() -> [FormRowView] {
    calculateFieldsVisibility()

    return [
      createBirthdayField(),
      FormRowSeparatorView(backgroundColor: UIColor.clear, height: CGFloat(20))
    ].compactMap { return $0 }
  }

  private func calculateFieldsVisibility() {
    showBirthdate = requiredData.getRequiredDataPointOf(type: .birthDate) != nil
  }
}

private extension BirthdayStep {
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
}
