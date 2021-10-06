//
//  IAPCardEnrolmentCheckerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 8/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import AptoUISDK

class IAPCardEnrolmentCheckerTests: XCTestCase {

    let EnrolledCard = "1111"
    let NotEnrolledCard = "4444"

    override class func setUp() {
        super.setUp()
    }
    
    func test_isCardEnrolledInPhoneWallet_returnsTrueIfTheCardIsEnrolled() {
        let library = makePassLibrary(items: ["1111", "2222"])
        let session = MockWatchConnectingSession(supported: true, paired: false)

        let sut = makeSUT(passKitAvailable: true, library: library, session: session)

        XCTAssertTrue(sut.isCardEnrolledInPhoneWallet(lastFourDigits: EnrolledCard))
    }
    
    func test_isCardEnrolledInPhoneWallet_returnsFalseIfTheCardIsNotEnrolled() {
        let pass_1 = PassLibraryItem(cardLastFourDigits: "1111", deviceAccountIdentifier: "abc123")
        let pass_2 = PassLibraryItem(cardLastFourDigits: "2222", deviceAccountIdentifier: "abc123")
        let library = [pass_1, pass_2]
        let manager = IAPCardEnrolmentCheckerStub(with: true, library: library)
        
        let checker = IAPCardEnrolmentChecker(with: manager)

        XCTAssertFalse(checker.isCardEnrolledInPhoneWallet(lastFourDigits: "4444"))
    }

    func test_isCardEnrolledInPairedWatchDevice_returnsTrueIfTheCardIsEnrolled() {
        let pass_1 = PassLibraryItem(cardLastFourDigits: "1111", deviceAccountIdentifier: "abc123")
        let pass_2 = PassLibraryItem(cardLastFourDigits: "2222", deviceAccountIdentifier: "abc123")
        let library = [pass_1, pass_2]
        let manager = IAPCardEnrolmentCheckerStub(with: true, library: library)
        let session = MockWatchConnectingSession(supported: true, paired: true)
        
        let checker = IAPCardEnrolmentChecker(with: manager, session: session)

        XCTAssertTrue(checker.isCardEnrolledInPhoneWallet(lastFourDigits: "1111"))
    }

    func test_isCardEnrolledInPairedWatchDevice_returnsFalseIfTheCardIsNotEnrolled() {
        let pass_1 = PassLibraryItem(cardLastFourDigits: "1111", deviceAccountIdentifier: "abc123")
        let pass_2 = PassLibraryItem(cardLastFourDigits: "2222", deviceAccountIdentifier: "abc123")
        let library = [pass_1, pass_2]
        let manager = IAPCardEnrolmentCheckerStub(with: true, library: library)
        let session = MockWatchConnectingSession(supported: true, paired: true)
        
        let checker = IAPCardEnrolmentChecker(with: manager, session: session)

        XCTAssertFalse(checker.isCardEnrolledInPhoneWallet(lastFourDigits: "4444"))
    }
    
    private func makeSUT(passKitAvailable: Bool, library: [PassLibraryItem], session: MockWatchConnectingSession) -> IAPCardEnrolmentChecker {
        let manager = IAPCardEnrolmentCheckerStub(with: passKitAvailable, library: library)
        return IAPCardEnrolmentChecker(with: manager, session: session)
    }
    
    private func makeItems(lastFourDigits: String) -> PassLibraryItem {
        PassLibraryItem(cardLastFourDigits: lastFourDigits, deviceAccountIdentifier: "abc123")
    }
    
    private func makePassLibrary(items: [String]) -> [PassLibraryItem] {
        items.map(makeItems(lastFourDigits:))
    }
}


private class IAPCardEnrolmentCheckerStub: InAppPassLibrary {
    private let passkitAvailable: Bool
    private let library: [PassLibraryItem]
    
    init(with available: Bool, library: [PassLibraryItem]) {
        self.passkitAvailable = available
        self.library = library
    }
    
    func isPassKitAvailable() -> Bool {
        passkitAvailable
    }
    
    func passes() -> [PassLibraryItem] {
        library
    }
    
    func remotePasses() -> [PassLibraryItem] {
        library
    }
}

private class MockWatchConnectingSession: WatchConnectingSession {
    private let paired: Bool
    private let supported: Bool
    
    init(supported: Bool, paired: Bool) {
        self.paired = paired
        self.supported = supported
    }
    
    var isSupported: Bool {
        supported
    }

    var isPaired: Bool {
        paired
    }
}
