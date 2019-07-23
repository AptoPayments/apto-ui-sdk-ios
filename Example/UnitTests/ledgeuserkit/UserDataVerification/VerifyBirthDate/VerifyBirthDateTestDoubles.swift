//
//  VerifyBirthDateTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class VerifyBirthDateModuleSpy: UIModuleSpy, VerifyBirthDateModuleProtocol {
  var onVerificationPassed: ((VerifyBirthDateModule, Verification) -> Void)?
}
