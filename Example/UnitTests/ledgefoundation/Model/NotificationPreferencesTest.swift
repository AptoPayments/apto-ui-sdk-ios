//
// NotificationPreferencesTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/03/2019.
//

@testable import AptoSDK
import XCTest

class NotificationPreferencesTest: XCTestCase {
    private var sut: NotificationPreferences! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let group1 = NotificationGroup(groupId: .paymentSuccessful,
                                           category: .cardActivity,
                                           state: .disabled,
                                           channel: NotificationGroup.Channel(push: true, email: true))
    private let group2 = NotificationGroup(groupId: .atmWithdrawal,
                                           category: .cardActivity,
                                           state: .enabled,
                                           channel: NotificationGroup.Channel(push: true, email: false))

    override func setUp() {
        super.setUp()

        sut = NotificationPreferences(preferences: [group1, group2])
    }

    // swiftlint:disable force_cast
    func testJsonSerializeReturnsExpectedStructure() {
        // When
        let json = sut.jsonSerialize()

        // Then
        let preferences = json["preferences"]
        XCTAssertNotNil(preferences)
        XCTAssertTrue(preferences is [[String: AnyObject]])
        let preferencesArray = preferences as! [[String: AnyObject]]
        XCTAssertEqual(2, preferencesArray.count)
    }
    // swiftlint:enable force_cast
}
