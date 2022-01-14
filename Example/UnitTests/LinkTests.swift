//
//  LinkTests.swift
//  LinkTests
//
//  Created by Ivan Oliver Martínez on 07/03/2017.
//
//

import XCTest

class LinkTestCase: XCTestCase {
    func assertMockCalledOnce(mock: Mock, methodName: String, file: String = #file, line: UInt = #line) {
        let callCount = mock.callCount(methodName: methodName)
        if callCount != 1 {
            recordFailure(withDescription: "Method \(methodName) called \(callCount) times", inFile: file,
                          atLine: Int(line), expected: true)
        }
    }
}

struct CallLog {
    let methodName: String
    var callCount: Int
}

protocol Mock {
    var callStack: [String: CallLog] { get set }
}

protocol Stub {
    var methodStubs: [String: AnyObject] { get set }
}

extension Mock {
    mutating func registerCall(methodName: String) {
        guard var callLog = callStack[methodName] else {
            callStack[methodName] = CallLog(methodName: methodName, callCount: 1)
            return
        }
        callLog.callCount += 1
    }

    func callCount(methodName: String) -> Int {
        guard let callLog = callStack[methodName] else {
            return 0
        }
        return callLog.callCount
    }
}

extension Stub {
    mutating func registerReturnValue(methodName: String, returnValue: AnyObject) {
        methodStubs[methodName] = returnValue
    }

    func returnValueFor(methodName: String) -> AnyObject? {
        return methodStubs[methodName]
    }
}
