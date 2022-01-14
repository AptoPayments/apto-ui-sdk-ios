//
//  Mocks.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/05/2017.
//

@testable import AptoSDK

class MockVerification: Verification, Mock, Stub {
    var callStack: [String: CallLog] = [:]
    var methodStubs: [String: AnyObject] = [:]

    override func copyWithZone(_: NSZone?) -> AnyObject {
        var wself = self
        wself.registerCall(methodName: #function)

        if let returnValue = returnValueFor(methodName: #function) {
            return returnValue
        } else {
            return self
        }
    }
}
