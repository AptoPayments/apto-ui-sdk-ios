//
//  UserDataCollectorStepFactory.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 31/07/2018.
//
//

import AptoSDK

class UserDataCollectorStepFactory {
  private let requiredData: RequiredDataPointList
  private let userData: DataPointList
  private let mode: UserDataCollectorFinalStepMode
  private let primaryCredentialType: DataPointType
  private let secondaryCredentialType: DataPointType
  private let googleGeocodingAPIKey: String?
  private let uiConfig: UIConfig
  private let config: UserDataCollectorConfig
  private let linkHandler: LinkHandler

  init(requiredData: RequiredDataPointList,
       userData: DataPointList,
       mode: UserDataCollectorFinalStepMode,
       primaryCredentialType: DataPointType,
       secondaryCredentialType: DataPointType,
       googleGeocodingAPIKey: String?,
       uiConfig: UIConfig,
       config: UserDataCollectorConfig,
       router: UserDataCollectorRouterProtocol) {
    self.requiredData = requiredData
    self.userData = userData
    self.mode = mode
    self.primaryCredentialType = primaryCredentialType
    self.secondaryCredentialType = secondaryCredentialType
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
    self.uiConfig = uiConfig
    self.config = config
    self.linkHandler = LinkHandler(urlHandler: router)
  }

  func handler(for step: DataCollectorStep) -> DataCollectorStepProtocol {
    switch step {
    case .info:
      return InfoStep(requiredData: requiredData,
                      userData: userData,
                      primaryCredentialType: primaryCredentialType,
                      uiConfig: uiConfig)
    case .address:
      return AddressStep(requiredData: requiredData,
                         userData: userData,
                         uiConfig: uiConfig,
                         googleGeocodingApiKey: googleGeocodingAPIKey)
    case .birthDaySSN:
      return BirthdayStep(requiredData: requiredData,
                             secondaryCredentialType: secondaryCredentialType,
                             userData: userData,
                             mode: mode,
                             uiConfig: uiConfig,
                             linkHandler: linkHandler)
    case .ssn:
        return SSNStep(requiredData: requiredData,
                       secondaryCredentialType: secondaryCredentialType,
                       userData: userData,
                       mode: mode,
                       uiConfig: uiConfig,
                       linkHandler: linkHandler)
    }
  }
}
