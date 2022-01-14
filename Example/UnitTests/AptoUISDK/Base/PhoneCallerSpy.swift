//
//  PhoneCaller.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 23/10/2018.
//

import AptoSDK
@testable import AptoUISDK

class PhoneCallerSpy: DummyPhoneCaller {
    private(set) var callCalled = false
    override func call(phoneNumberURL: URL, from module: UIModule, completion: @escaping () -> Void) {
        callCalled = true
        super.call(phoneNumberURL: phoneNumberURL, from: module, completion: completion)
    }
}
