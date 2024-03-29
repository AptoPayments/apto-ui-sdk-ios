//
//  AddMoneyViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 26/1/21.
//

import SnapKit
import SnapshotTesting
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class AddMoneyViewTests: XCTestCase {
    func test_headerTextView_rendersViewWithText() {
        let view = HeaderTextView(uiconfig: UIConfig.default, text: "Add Money")
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }

    func test_actionDetailView_rendersViewWithTitleSubtitleAndChevron() {
        let view = DetailActionView(uiconfig: UIConfig.default, textTitle: "Debit card transfer", textSubTitle: "Instant deposit with a credit card")
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }

    func test_addMoneyView_rendersView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.65)

        let bottomView = AddMoneyView(uiconfig: UIConfig.default)
        backgroundView.addSubview(bottomView)

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(200)
        }
        let vc = HostViewController(with: backgroundView)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
