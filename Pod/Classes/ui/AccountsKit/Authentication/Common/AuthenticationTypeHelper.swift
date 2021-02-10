//
//  AuthenticationTypeHelper.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 29/1/21.
//

import Foundation
import AptoSDK

struct AuthenticationSettingContext {
    let isGlobalFaceIdEnabled: Bool
    let isLocalFaceIdEnabled: Bool
    let pciAuthenticationType: PCIAuthType
    
    var shouldAuthenticateWithFaceId: Bool {
        isGlobalFaceIdEnabled && isLocalFaceIdEnabled
    }
}

struct AuthenticationTypeHelper {
    private init() {}
    
    static func authenticationMode(with context: AuthenticationSettingContext) -> AuthenticationMode {
        switch context.pciAuthenticationType {
        case .pinOrBiometrics:
            return context.shouldAuthenticateWithFaceId ? .allAvailables : .passcode
        case .biometrics:
            return context.shouldAuthenticateWithFaceId ? .biometry : .none
        default:
            return .none
        }
    }
}

