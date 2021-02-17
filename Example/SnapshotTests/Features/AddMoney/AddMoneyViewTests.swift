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
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.65)

        let bottomView = AddMoneyView(uiconfig: UIConfig.default)
        bottomView.configure(with: "crd_12345678")
        backgroundView.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(200)
        }
        backgroundView.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        
        assertSnapshot(matching: backgroundView, as: .image)
    }
}
