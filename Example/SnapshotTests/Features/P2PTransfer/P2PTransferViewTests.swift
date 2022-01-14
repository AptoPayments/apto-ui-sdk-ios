//
//  P2PTransferViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 22/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SnapKit
import SnapshotTesting
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class P2PTransferViewTests: XCTestCase {
    func test_transferView_rendersView() {
        let view = P2PTransferView(uiconfig: UIConfig.default, defaultCountry: "US")
        view.configureView(for: .email, intro: "p2p_transfer.main_screen.intro.email_description")
        view.backgroundColor = .white
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
