//
//  AddMoneyViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 26/1/21.
//

import XCTest
import SnapshotTesting
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class AddMoneyViewTests: XCTestCase {
    
    func test_headerTextView_rendersViewWithText() {
        let view = HeaderTextView(uiconfig: UIConfig.default, text: "Add Money")
        view.snp.makeConstraints { make in
            make.height.equalTo(58)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }

    func test_actionDetailView_rendersViewWithTitleSubtitleAndChevron() {
        let view = DetailActionView(uiconfig: UIConfig.default, textTitle: "Debit card transfer", textSubTitle: "Instant deposit with a credit card")
        view.snp.makeConstraints { make in
            make.height.equalTo(72)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }

    func test_addMoneyView_rendersView() {
        let vc = AddMoneyViewController(uiConfiguration: UIConfig.default)
        assertSnapshot(matching: vc, as: .image(on: .iPhoneXsMax))
    }
}
