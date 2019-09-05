//
//  AptoPlatformUITest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 22/07/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class AptoPlatformUITest: XCTestCase {

  // SUT
  private var sut: AptoPlatform = AptoPlatform.defaultManager()
  // Collaborators
  private let uiDelegate = AptoPlatformUIDelegateSpy()

  func test() {
    // Given
    let googleMapsApiKey = "api-key"

    // When
    sut.startCardFlow(from: UIViewController(), mode: .standalone, googleMapsApiKey: googleMapsApiKey) { _ in }

    // Then
    XCTAssertEqual(googleMapsApiKey, sut.googleMapsApiKey)
  }

  func testUIDelegateCalledWhenNoNetworkDetected() {
    // Given
    sut.uiDelegate = uiDelegate

    // When
    NotificationCenter.default.post(Notification(name: .NetworkNotReachableNotification))

    // Then
    XCTAssertTrue(uiDelegate.shouldShowNoNetworkUICalled)
  }

  func testUIDelegateCalledWhenNetworkRecovered() {
    // Given
    sut.uiDelegate = uiDelegate

    // When
    NotificationCenter.default.post(Notification(name: .NetworkReachableNotification))

    // Then
    XCTAssertTrue(uiDelegate.shouldShowNoNetworkUICalled)
  }

  func testUIDelegateCalledWhenServerMaintenanceDetected() {
    // Given
    sut.uiDelegate = uiDelegate

    // When
    NotificationCenter.default.post(Notification(name: .ServerMaintenanceNotification))

    // Then
    XCTAssertTrue(uiDelegate.shouldShowServerMaintenanceUICalled)
  }
}

private class AptoPlatformUIDelegateSpy: AptoPlatformUIDelegate {
  var uiDelegate: AptoPlatformUIDelegate?

  private(set) var shouldShowNoNetworkUICalled = false
  func shouldShowNoNetworkUI() -> Bool {
    shouldShowNoNetworkUICalled = true
    return true
  }

  private(set) var shouldShowServerMaintenanceUICalled = false
  func shouldShowServerMaintenanceUI() -> Bool {
    shouldShowServerMaintenanceUICalled = true
    return true
  }
}
