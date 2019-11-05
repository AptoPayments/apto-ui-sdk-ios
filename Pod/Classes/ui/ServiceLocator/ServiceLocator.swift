//
//  ServiceLocator.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import AptoSDK

class ServiceLocator: ServiceLocatorProtocol {
  static let shared: ServiceLocatorProtocol = ServiceLocator()

  lazy var moduleLocator: ModuleLocatorProtocol = ModuleLocator(serviceLocator: self)
  lazy var presenterLocator: PresenterLocatorProtocol = PresenterLocator(serviceLocator: self)
  lazy var interactorLocator: InteractorLocatorProtocol = InteractorLocator(serviceLocator: self)
  lazy var viewLocator: ViewLocatorProtocol = ViewLocator(serviceLocator: self)
  lazy var systemServicesLocator: SystemServicesLocatorProtocol = SystemServicesLocator()

  private(set) var platform: AptoPlatformProtocol = AptoPlatform.defaultManager()
  var uiConfig: UIConfig! // swiftlint:disable:this implicitly_unwrapped_optional
  lazy var analyticsManager: AnalyticsServiceProtocol = AnalyticsManager.instance
  lazy var notificationHandler: NotificationHandler = NotificationHandlerImpl()
}
