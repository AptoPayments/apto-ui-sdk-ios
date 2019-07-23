//
// NotificationGroupTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/03/2019.
//

import XCTest
@testable import AptoSDK

class NotificationGroupTest: XCTestCase {
  // Collaborators
  private let groupId = NotificationGroup.GroupId.paymentSuccessful
  private let category = NotificationGroup.Category.cardActivity

  // swiftlint:disable force_cast
  func testEmailAndPushChannelJsonSerializeReturnsExpectedObject() {
    // Given
    let channel = NotificationGroup.Channel(push: true, email: false)
    let sut = NotificationGroup(groupId: groupId, category: category, state: .enabled, channel: channel)

    // When
    let json = sut.jsonSerialize()

    // Then
    let expectedChannels: [String: Bool] = [
      "email": false,
      "push": true
    ]
    XCTAssertEqual("payment_successful", json["group_id"] as! String)
    XCTAssertEqual(expectedChannels, json["active_channels"] as! [String: Bool])
  }

  func testPushAndSmsChannelJsonSerializeReturnsExpectedObject() {
    // Given
    let channel = NotificationGroup.Channel(push: true, sms: false)
    let sut = NotificationGroup(groupId: groupId, category: category, state: .enabled, channel: channel)

    // When
    let json = sut.jsonSerialize()

    // Then
    let expectedChannels: [String: Bool] = [
      "sms": false,
      "push": true
    ]
    XCTAssertEqual("payment_successful", json["group_id"] as! String)
    XCTAssertEqual(expectedChannels, json["active_channels"] as! [String: Bool])
  }
  // swiftlint:enable force_cast
}
