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
  open var primaryAuthCredential: DataPointType
  open var secondaryAuthCredential: DataPointType

  public init(mode: UserDataCollectorFinalStepMode,
              backButtonMode: UIViewControllerLeftButtonMode,
              skipSteps: Bool,
              allowUserLogin: Bool,
              strictAddressValidation: Bool,
              googleGeocodingAPIKey: String,
              userRequiredData: RequiredDataPointList,
              primaryAuthCredential: DataPointType,
              secondaryAuthCredential: DataPointType) {
    self.mode = mode
    self.backButtonMode = backButtonMode
    self.skipSteps = skipSteps
    self.allowUserLogin = allowUserLogin
    self.strictAddressValidation = strictAddressValidation
    self.googleGeocodingAPIKey = googleGeocodingAPIKey
    self.userRequiredData = userRequiredData
    self.primaryAuthCredential = primaryAuthCredential
    self.secondaryAuthCredential = secondaryAuthCredential
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
              primaryAuthCredential: contextConfiguration.projectConfiguration.primaryAuthCredential,
              secondaryAuthCredential: contextConfiguration.projectConfiguration.secondaryAuthCredential)
  }
}
