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
  private var sut: AptoPlatform = AptoPlatform.defaultManager()

  func test() {
    // Given
    let googleMapsApiKey = "api-key"

    // When
    sut.startCardFlow(from: UIViewController(), mode: .standalone, googleMapsApiKey: googleMapsApiKey) { _ in }

    // Then
    XCTAssertEqual(googleMapsApiKey, sut.googleMapsApiKey)
  }
}
