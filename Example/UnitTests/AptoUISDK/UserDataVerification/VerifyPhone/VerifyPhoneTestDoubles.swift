//
//  VerifyPhoneTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class VerifyPhoneModuleSpy: UIModuleSpy, VerifyPhoneModuleProtocol {
    open var onVerificationPassed: ((_ verifyPhoneModule: VerifyPhoneModule, _ verification: Verification) -> Void)?
}
