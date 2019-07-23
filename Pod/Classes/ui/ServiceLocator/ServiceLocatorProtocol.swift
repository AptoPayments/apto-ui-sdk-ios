//
//  ServiceLocatorProtocol.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/06/2018.
//
//

import AptoSDK

protocol ServiceLocatorProtocol: class {
  var moduleLocator: ModuleLocatorProtocol { get }
  var presenterLocator: PresenterLocatorProtocol { get }
  var interactorLocator: InteractorLocatorProtocol { get }
  var viewLocator: ViewLocatorProtocol { get }

  var platform: AptoPlatformProtocol { get }
  var uiConfig: UIConfig! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol { get }
}
