//
//  ServerMaintenanceErrorInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

import AptoSDK

class ServerMaintenanceErrorInteractor: ServerMaintenanceErrorInteractorProtocol {
  private let aptoPlatform: AptoPlatformProtocol

  init(aptoPlatform: AptoPlatformProtocol) {
    self.aptoPlatform = aptoPlatform
  }

  func runPendingRequests() {
    aptoPlatform.runPendingNetworkRequests()
  }
}
