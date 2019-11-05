//
//  UserDataCollectorInteractorNewUserStrategy.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/02/2017.
//
//

import Foundation
import AptoSDK

class UserDataCollectorInteractorNewUserStrategy: UserDataCollectorInteractorStrategy {

  override func shouldShowEmailVerification(userData: DataPointList,
                                            userRequiredData: RequiredDataPointList) -> Bool {
    if let requiredEmailSpec = userRequiredData.getRequiredDataPointOf(type: .email),
        requiredEmailSpec.verificationRequired {
      return true
    }
    else {
      guard let phoneVerification = userData.phoneDataPoint.verification, phoneVerification.status == .passed else {
        return false
      }
//      guard phoneVerification.alternateCredentials?.count > 0 else {
//        return false
//      }
      if let emailVerification = userData.emailDataPoint.verification, emailVerification.status == .passed {
        return false
      }
      return true
    }
  }

  override func shouldShowBirthdateVerification(userData: DataPointList,
                                                userRequiredData: RequiredDataPointList) -> Bool {
    return false
  }

  override func shouldRecoverUserAccount(userData: DataPointList) -> Bool {
    if !config.allowUserLogin {
      return false
    }
    guard let phoneVerification = userData.phoneDataPoint.verification, phoneVerification.status == .passed else {
      return false
    }
    guard let emailVerification = userData.emailDataPoint.verification, emailVerification.status == .passed else {
      return false
    }
    return true
  }

  override func shouldUpdateUserData(_ userData: DataPointList, initialUserData: DataPointList) -> DataPointList? {
    return nil
  }

  override func shouldCreateNewUser(_ userData: DataPointList) -> Bool {
    return true
  }
}
