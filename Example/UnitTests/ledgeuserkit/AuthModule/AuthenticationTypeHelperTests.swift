//
//  AuthenticationTypeHelperTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 29/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class AuthenticationTypeHelperTests: XCTestCase {

    func test_authMode_isBiometryWhenFaceIdIsEnabledAndAuthPciIsPinOrBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: true,
                                                   isLocalFaceIdEnabled: true,
                                                   pciAuthenticationType: .pinOrBiometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.allAvailables)
    }

    func test_authMode_isPasscodeWhenLocalFaceIdIsDisabledAndAuthPciIsPinOrBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: true,
                                                   isLocalFaceIdEnabled: false,
                                                   pciAuthenticationType: .pinOrBiometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.passcode)
    }

    
    func test_authMode_isPasscodeWhenGlobalFaceIdIsDisabledAndAuthPciIsPinOrBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: false,
                                                   isLocalFaceIdEnabled: true,
                                                   pciAuthenticationType: .pinOrBiometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.passcode)
    }
    
    func test_authMode_isPasscodeWhenFaceIdIsDisabledAndAuthPciIsPinOrBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: false,
                                                   isLocalFaceIdEnabled: false,
                                                   pciAuthenticationType: .pinOrBiometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.passcode)
    }

    func test_authMode_isBiometryWhenFaceIdIsEnabledAndAuthPciIsBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: true,
                                                   isLocalFaceIdEnabled: true,
                                                   pciAuthenticationType: .biometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.biometry)
    }
    
    func test_authMode_isNoneWhenLocalFaceIdIsDisabledAndAuthPciIsBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: true,
                                                   isLocalFaceIdEnabled: false,
                                                   pciAuthenticationType: .biometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.none)
    }

    func test_authMode_isNoneWhenGlobalFaceIdIsDisabledAndAuthPciIsBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: false,
                                                   isLocalFaceIdEnabled: true,
                                                   pciAuthenticationType: .biometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.none)
    }

    func test_authMode_isNoneWhenFaceIdIsDisabledAndAuthPciIsBiometrics() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: false,
                                                   isLocalFaceIdEnabled: false,
                                                   pciAuthenticationType: .biometrics)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.none)
    }

    func test_authMode_isNoneWhenAuthPciIsNone() {
        let context = AuthenticationSettingContext(isGlobalFaceIdEnabled: false,
                                                   isLocalFaceIdEnabled: false,
                                                   pciAuthenticationType: .none)
        let authenticationType = AuthenticationTypeHelper.authenticationMode(with: context)
        
        XCTAssertEqual(authenticationType, AuthenticationMode.none)
    }
}
