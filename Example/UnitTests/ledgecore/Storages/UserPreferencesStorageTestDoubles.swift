//
//  UserPreferencesStorageTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 12/02/2020.
//

@testable import AptoSDK

class UserPreferencesStorageFake: UserPreferencesStorageProtocol {
  var shouldShowDetailedCardActivity: Bool = false
  var shouldUseBiometric: Bool = false
}
