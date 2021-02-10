//
//  AddMoneyViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 25/1/21.
//

import XCTest
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class AddMoneyViewControllerTests: XCTestCase {
    
    func test_init_rendersAddMoneyView() throws {
        let uiConfig = ModelDataProvider.provider.uiConfig
        let sut = AddMoneyViewController(uiConfiguration: uiConfig)
        
        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.view)
        XCTAssertTrue(sut.view.subviews.count > 0)
        XCTAssertTrue(((sut.view.subviews.first?.isKind(of: AddMoneyView.self)) != nil))
    }
}
