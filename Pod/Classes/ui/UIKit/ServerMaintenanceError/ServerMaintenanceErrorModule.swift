//
//  ServerMaintenanceErrorModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/07/2018.
//
//

import AptoSDK

protocol ServerMaintenanceErrorInteractorProtocol: class {
  func runPendingRequests()
}

protocol ServerMaintenanceErrorEventHandler: class {
  func retryTapped()
  func viewLoaded()
}

protocol ServerMaintenanceErrorModuleProtocol: UIModuleProtocol {
  func pendingRequestsExecuted()
}

protocol ServerMaintenanceErrorPresenterProtocol: ServerMaintenanceErrorEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var router: ServerMaintenanceErrorModuleProtocol! { get set }
  var interactor: ServerMaintenanceErrorInteractorProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol? { get set }
}

class ServerMaintenanceErrorModule: UIModule, ServerMaintenanceErrorModuleProtocol {
  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let presenter = serviceLocator.presenterLocator.serverMaintenanceErrorPresenter()
    let interactor = serviceLocator.interactorLocator.serverMaintenanceErrorInteractor()
    let viewController = serviceLocator.viewLocator.serverMaintenanceErrorView(uiConfig: serviceLocator.uiConfig,
                                                                               eventHandler: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = serviceLocator.analyticsManager
    completion(.success(viewController))
  }

  func pendingRequestsExecuted() {
    close()
  }
}
