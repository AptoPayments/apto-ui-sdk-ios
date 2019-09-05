//
//  AptoPlatformUIProtocol.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 04/09/2019.
//

import Foundation

@objc public protocol AptoPlatformUIDelegate {
  /**
   * Called when a no network situation is detected, to ask the delegate if the UI SDK should show specific UI
   * to explain the user that the network is not available. Used too when the network is restored to know if the
   * UI SDK should dismiss the No network UI.
   */
  @objc optional func shouldShowNoNetworkUI() -> Bool

  /**
   * Called when a network request fails because our server is not available, to ask the delegate if the UI SDK should
   * show specific UI to explain the user that the server is in maintenance mode.
   */
  @objc optional func shouldShowServerMaintenanceUI() -> Bool
}
