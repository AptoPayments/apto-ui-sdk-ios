//
//  UserDataCollectorInteractorStrategy.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/02/2017.
//
//

import AptoSDK
import Foundation

class UserDataCollectorInteractorStrategy {
    let config: UserDataCollectorConfig

    init(config: UserDataCollectorConfig) {
        self.config = config
    }

    func shouldShowPhoneVerification(userData: DataPointList,
                                     userRequiredData: RequiredDataPointList) -> Bool
    {
        // If the phone is the project's primary credential, and it's not been yet verified, we must verify it
        let phoneVerification = userData.phoneDataPoint.verification
        if config.primaryAuthCredential == .phoneNumber,
           phoneVerification == nil || !phoneVerification!.verified()
        { // swiftlint:disable:this force_unwrapping
            return true
        } else {
            guard let requiredPhoneSpec = userRequiredData.getRequiredDataPointOf(type: .phoneNumber) else {
                return false
            }
            if !requiredPhoneSpec.verificationRequired {
                return false
            } else {
                guard userData.phoneDataPoint.verified == false else {
                    return false
                }
                guard let verification = userData.phoneDataPoint.verification else {
                    return true
                }
                return !verification.verified()
            }
        }
    }

    func shouldShowEmailVerification(userData _: DataPointList,
                                     userRequiredData _: RequiredDataPointList) -> Bool
    {
        return false
    }

    func shouldShowBirthdateVerification(userData _: DataPointList,
                                         userRequiredData _: RequiredDataPointList) -> Bool
    {
        return false
    }

    func shouldRecoverUserAccount(userData _: DataPointList) -> Bool {
        return false
    }

    func shouldUpdateUserData(_: DataPointList, initialUserData _: DataPointList) -> DataPointList? {
        return nil
    }

    func shouldCreateNewUser(_: DataPointList) -> Bool {
        return false
    }
}
