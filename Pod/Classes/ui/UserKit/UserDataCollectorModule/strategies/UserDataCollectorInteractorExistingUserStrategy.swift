//
//  UserDataCollectorInteractorExistingUserStrategy.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/02/2017.
//
//

import AptoSDK
import Foundation

class UserDataCollectorInteractorExistingUserStrategy: UserDataCollectorInteractorStrategy {
    override func shouldShowEmailVerification(userData _: DataPointList,
                                              userRequiredData _: RequiredDataPointList) -> Bool
    {
        return false
    }

    override func shouldShowBirthdateVerification(userData _: DataPointList,
                                                  userRequiredData _: RequiredDataPointList) -> Bool
    {
        return false
    }

    override func shouldRecoverUserAccount(userData _: DataPointList) -> Bool {
        return false
    }

    override func shouldUpdateUserData(_ userData: DataPointList,
                                       initialUserData: DataPointList) -> DataPointList?
    {
        let differences = initialUserData.modifiedDataPoints(compareWith: userData)
        if !differences.dataPoints.isEmpty {
            return differences
        }
        return nil
    }

    override func shouldCreateNewUser(_: DataPointList) -> Bool {
        return false
    }
}
