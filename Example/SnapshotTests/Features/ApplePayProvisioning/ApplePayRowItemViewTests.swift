//
//  ApplePayRowItemViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 13/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SnapshotTesting
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class ApplePayRowItemViewTests: XCTestCase {

    func test_applePayRow_rendersView() {
        let view = ApplePayRowItemView(with: "card_settings.apple_pay.add_to_wallet.title".podLocalized(),
                                       uiconfig: UIConfig.default)
        
        view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }
}
