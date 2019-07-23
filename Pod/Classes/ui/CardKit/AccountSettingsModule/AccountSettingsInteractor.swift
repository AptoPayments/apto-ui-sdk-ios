//
//  AccountSettingsInteractor.swift
 // AptoSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import Foundation
import AptoSDK

class AccountSettingsInteractor: AccountSettingsInteractorProtocol {
  private let platform: AptoPlatformProtocol

  init(platform: AptoPlatformProtocol) {
    self.platform = platform
  }

  func logoutCurrentUser() {
    platform.logout()
  }
}
