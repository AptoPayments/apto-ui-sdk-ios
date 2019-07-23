//
//  ServerMaintenanceErrorTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 18/07/2018.
//

import AptoSDK
@testable import AptoUISDK

class ServerMaintenanceErrorInteractorSpy:  ServerMaintenanceErrorInteractorProtocol {
  private(set) var runPendingRequestsCalled = false
  func runPendingRequests() {
    runPendingRequestsCalled = true
  }
}

class ServerMaintenanceErrorPresenterSpy: ServerMaintenanceErrorPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ServerMaintenanceErrorModuleProtocol!
  var interactor: ServerMaintenanceErrorInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var retryTappedCalled = false
  func retryTapped() {
    retryTappedCalled = true
  }
}

class ServerMaintenanceErrorModuleSpy: UIModule, ServerMaintenanceErrorModuleProtocol {
  private(set) var pendingRequestsExecutedCalled = false
  func pendingRequestsExecuted() {
    pendingRequestsExecutedCalled = true
  }
}
