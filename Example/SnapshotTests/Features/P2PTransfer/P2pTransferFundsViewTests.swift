//
//  P2pTransferFundsViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 30/8/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SnapKit
import SnapshotTesting
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class P2pTransferFundsViewTests: XCTestCase {
    func test_transferFundsView_rendersViewWithZeroAmount() {
        let view = P2PTransferFundsView(uiconfig: UIConfig.default)
        view.backgroundColor = .white
        view.showActionButton(false)
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
