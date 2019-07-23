//
//  UserDataCollectorConfig.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 14/10/2016.
//
//

import Foundation
import AptoSDK

@objc open class UserDataCollectorConfig: NSObject {
  open var mode: UserDataCollectorFinalStepMode
  open var backButtonMode: UIViewControllerLeftButtonMode
  open var skipSteps: Bool
  open var allowUserLogin: Bool
  open var strictAddressValidation: Bool
  open var googleGeocodingAPIKey: String?
  open var defaultCountryCode: Int = 1
  open var userRequiredData: RequiredDataPointList
  open var incomeTypes: [IncomeType]
  open var housingTypes: [HousingType]
  open var salaryFrequencies: [SalaryFrequency]
  open var timeAtAddressOptions: [TimeAtAddressOption]
  open var availableCreditScoreOptions: [CreditScoreOption]
  open var primaryAuthCredential: DataPointType
  open var secondaryAuthCredential: DataPointType
  open var grossIncomeRange: AmountRangeConfiguration

  public init(mode: UserDataCollectorFinalStepMode,
              backButtonMode: UIViewControllerLeftButtonMode,
              skipSteps: Bool,
              allowUserLogin: Bool,
              strictAddressValidation: Bool,
              googleGeocodingAPIKey: String,
              userRequiredData: RequiredDataPointList,
              incomeTypes: [IncomeType],
              housingTypes: [HousingType],
              salaryFrequencies: [SalaryFrequency],
              timeAtAddressOptions: [TimeAtAddressOption],
              creditScoreOptions: [CreditScoreOption],
              primaryAuthCredential: DataPointType,
              secondaryAuthCredential: DataPointType,
              grossIncomeRange: AmountRangeConfiguration) {
    self.mode = mode
    self.backButtonMode = backButtonMode
    self.skipSteps = skipSteps
    self.allowUserLogin = allowUserLogin
    self.strictAddressValidation = strictAddressValidation
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
    self.userRequiredData = userRequiredData
    self.incomeTypes = incomeTypes
    self.housingTypes = housingTypes
    self.salaryFrequencies = salaryFrequencies
    self.timeAtAddressOptions = timeAtAddressOptions
    self.availableCreditScoreOptions = creditScoreOptions
    self.primaryAuthCredential = primaryAuthCredential
    self.secondaryAuthCredential = secondaryAuthCredential
    self.grossIncomeRange = grossIncomeRange
  }

  public convenience init(contextConfiguration: ContextConfiguration,
                          mode: UserDataCollectorFinalStepMode,
                          backButtonMode: UIViewControllerLeftButtonMode,
                          userRequiredData: RequiredDataPointList,
                          googleGeocodingAPIKey: String) {
    self.init(mode: mode,
              backButtonMode: backButtonMode,
              skipSteps: contextConfiguration.projectConfiguration.skipSteps,
              allowUserLogin: contextConfiguration.projectConfiguration.allowUserLogin,
              strictAddressValidation: contextConfiguration.projectConfiguration.strictAddressValidation,
              googleGeocodingAPIKey: googleGeocodingAPIKey,
              userRequiredData: userRequiredData,
              incomeTypes: contextConfiguration.projectConfiguration.incomeTypes,
              housingTypes: contextConfiguration.projectConfiguration.housingTypes,
              salaryFrequencies: contextConfiguration.projectConfiguration.salaryFrequencies,
              timeAtAddressOptions: contextConfiguration.projectConfiguration.timeAtAddressOptions,
              creditScoreOptions: contextConfiguration.projectConfiguration.creditScoreOptions,
              primaryAuthCredential: contextConfiguration.projectConfiguration.primaryAuthCredential,
              secondaryAuthCredential: contextConfiguration.projectConfiguration.secondaryAuthCredential,
              grossIncomeRange: contextConfiguration.projectConfiguration.grossIncomeRange)
  }
}
