//
//  InAppProvisioningHelper.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 14/4/21.
//

import PassKit
import AptoSDK

public protocol ApplePayInAppProvisioningProtocol {
    func shouldShowAppleWalletButton(iapEnabled: Bool) -> Bool
    func appleWalletButton() -> UIButton
}

public typealias AppleWalletButtonAction = (() -> Void)

public class InAppProvisioningHelper: ApplePayInAppProvisioningProtocol {
    
    static let appleWalletButtonTag = 223311
    static let appleWalletContainerViewTag = 223312

    public init() {}
    
    public func shouldShowAppleWalletButton(iapEnabled: Bool) -> Bool {
        let pLib = PKPassLibrary()
        let passes = pLib.passes(of: .payment)
        return iapEnabled && PKAddPaymentPassViewController.canAddPaymentPass() && passes.count == 0
    }
    
    public func appleWalletButton() -> UIButton {
        let button = PKAddPassButton(addPassButtonStyle: .blackOutline)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = InAppProvisioningHelper.appleWalletButtonTag
        return button
    }    
}
