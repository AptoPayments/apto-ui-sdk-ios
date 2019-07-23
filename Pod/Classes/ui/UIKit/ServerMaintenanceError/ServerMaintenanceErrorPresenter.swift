//
//  ServerMaintenanceErrorPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

import AptoSDK

class ServerMaintenanceErrorPresenter: ServerMaintenanceErrorPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ServerMaintenanceErrorModuleProtocol!
  var interactor: ServerMaintenanceErrorInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol?

  func viewLoaded() {
    analyticsManager?.track(event: Event.maintenance)
  }

  func retryTapped() {
    router.pendingRequestsExecuted()
    interactor.runPendingRequests()
  }
}
