//
//  ApplePayRowItemViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 13/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SnapKit
import SnapshotTesting
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class ApplePayRowItemViewTests: XCTestCase {
    func test_applePayRow_rendersView() {
        let view = ApplePayRowItemView(with: "card_settings.apple_pay.add_to_wallet.title".podLocalized(),
                                       uiconfig: UIConfig.default)

        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
