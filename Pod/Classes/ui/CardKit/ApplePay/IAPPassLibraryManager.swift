//
//  IAPPassLibraryManager.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 8/7/21.
//

import Foundation
import PassKit

public struct PassLibraryItem {
    let cardLastFourDigits: String
    let deviceAccountIdentifier: String
    
    public init(cardLastFourDigits: String, deviceAccountIdentifier: String) {
        self.cardLastFourDigits = cardLastFourDigits
        self.deviceAccountIdentifier = deviceAccountIdentifier
    }
}

public protocol InAppPassLibrary {
    func isPassKitAvailable() -> Bool
    func passes() -> [PassLibraryItem]
    func remotePasses() -> [PassLibraryItem]
}

public class IAPPassLibraryManager: InAppPassLibrary {
    public init() {}
    
    public func isPassKitAvailable() -> Bool {
        PKPassLibrary.isPassLibraryAvailable()
    }
    
    public func passes() -> [PassLibraryItem] {
        guard PKPassLibrary.isPassLibraryAvailable() else { return [] }
        return passes().compactMap(map(pkpass:))
    }
    
    public func remotePasses() -> [PassLibraryItem] {
        guard PKPassLibrary.isPassLibraryAvailable() else { return [] }
        return remotePasses().compactMap(map(pkpass:))
    }
    
    // MARK: Private methods
    private func passes() -> [PKPass] {
        let passLibrary = PKPassLibrary()
        if #available(iOS 13.4, *) {
            return passLibrary.passes(of: .secureElement)
        } else {
            return passLibrary.passes(of: .payment)
        }
    }

    private func remotePasses() -> [PKPass] {
        return PKPassLibrary().remotePaymentPasses()
    }

    private func cardLastFourDigits(for pass: PKPass) -> String? {
        if #available(iOS 13.4, *) {
            return pass.secureElementPass?.primaryAccountNumberSuffix
        } else {
            return pass.paymentPass?.primaryAccountNumberSuffix
        }
    }

    private func deviceAccountIdentifier(for pass: PKPass) -> String? {
        if #available(iOS 13.4, *) {
            return pass.secureElementPass?.deviceAccountIdentifier
        } else {
            return pass.paymentPass?.deviceAccountIdentifier
        }
    }

    private func map(pkpass: PKPass) -> PassLibraryItem? {
        guard let dai = self.deviceAccountIdentifier(for: pkpass) else { return nil }
        guard let lastFourDigits = self.cardLastFourDigits(for: pkpass) else { return nil }
        return PassLibraryItem(cardLastFourDigits: lastFourDigits, deviceAccountIdentifier: dai)
    }
}
