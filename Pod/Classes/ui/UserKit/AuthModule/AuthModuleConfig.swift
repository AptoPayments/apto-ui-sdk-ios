//
//  AuthModuleConfig.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

import AptoSDK

@objc open class AuthModuleConfig: NSObject {
    public let defaultCountryCode: Int
    public let primaryAuthCredential: DataPointType
    public let secondaryAuthCredential: DataPointType
    public let allowedCountries: [Country]
    public let mode: AptoUISDKMode

    public init(defaultCountryCode: Int = 1,
                primaryAuthCredential: DataPointType,
                secondaryAuthCredential: DataPointType,
                allowedCountries: [Country],
                mode: AptoUISDKMode)
    {
        self.defaultCountryCode = defaultCountryCode
        self.primaryAuthCredential = primaryAuthCredential
        self.secondaryAuthCredential = secondaryAuthCredential
        self.allowedCountries = allowedCountries
        self.mode = mode
    }

    public convenience init(projectConfiguration: ProjectConfiguration, mode: AptoUISDKMode) {
        self.init(primaryAuthCredential: projectConfiguration.primaryAuthCredential,
                  secondaryAuthCredential: projectConfiguration.secondaryAuthCredential,
                  allowedCountries: projectConfiguration.allowedCountries,
                  mode: mode)
    }
}
