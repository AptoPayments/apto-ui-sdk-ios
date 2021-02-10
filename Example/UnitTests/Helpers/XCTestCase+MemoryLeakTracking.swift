//
//  XCTestCase+MemoryLeakTracking.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 28/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
