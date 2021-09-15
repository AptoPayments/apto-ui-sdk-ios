//
//  IAPCardEnrolmentChecker.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 8/7/21.
//

import Foundation
import WatchConnectivity

public protocol WatchConnectingSession {
    var isSupported: Bool { get }
    var isPaired: Bool { get }
}

public class IAPCardEnrolmentChecker {
    private let passLibraryManager: InAppPassLibrary
    private let session: WatchConnectingSession
    
    public init(with manager: InAppPassLibrary = IAPPassLibraryManager(), session: WatchConnectingSession = WCSession.default) {
        self.passLibraryManager = manager
        self.session = session
    }
    
    public func isCardEnrolledInPhoneWallet(lastFourDigits: String) -> Bool {
        let passes = passLibraryManager.passes()
        return isCardEnrolled(lastFourDigits: lastFourDigits, into: passes)
    }

    public func isCardEnrolledInPairedWatchDevice(lastFourDigits: String) -> Bool {
        if hasPairedWatchDevices() {
            let passes = passLibraryManager.remotePasses()
            return isCardEnrolled(lastFourDigits: lastFourDigits, into: passes)
        } else {
            return true
        }
    }

    public func isCardEnrolled(lastFourDigits: String) -> Bool {
        isCardEnrolledInPhoneWallet(lastFourDigits: lastFourDigits) &&
        isCardEnrolledInPairedWatchDevice(lastFourDigits: lastFourDigits)
    }
    
    // MARK: Private methods
    private func isCardEnrolled(lastFourDigits: String, into passes: [PassLibraryItem]) -> Bool {
        passes.first { $0.cardLastFourDigits == lastFourDigits } != nil
    }
    
    private func hasPairedWatchDevices() -> Bool {
        guard session.isSupported else { return false }
        return session.isPaired
    }
}

extension WCSession: WatchConnectingSession {
    public var isSupported: Bool { Self.isSupported() }
}
