//
//  VerifyEmailTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class VerifyEmailModuleSpy: UIModuleSpy, VerifyEmailModuleProtocol {
    var onVerificationPassed: ((VerifyEmailModule, Verification) -> Void)?
}
