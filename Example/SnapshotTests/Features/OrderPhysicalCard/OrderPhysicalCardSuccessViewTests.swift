//
//  OrderPhysicalCardSuccessViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 24/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SnapKit
import SnapshotTesting
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class OrderPhysicalCardSuccessViewTests: XCTestCase {
    func test_orderPhysicalCardViewSuccess_rendersView() {
        let view = OrderPhysicalCardSuccessView(uiconfig: UIConfig.default)
        let card = ModelDataProvider.provider.cardWithDataToRenderACreditCardView
        view.configure(card: card)

        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
