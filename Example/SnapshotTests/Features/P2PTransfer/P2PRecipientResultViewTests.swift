//
//  P2PRecipientResultViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 28/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SnapshotTesting
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class P2PRecipientResultViewTests: XCTestCase {
    
    func test_recipientResultView_rendersViewWithRecipient() {
        let view = P2PRecipientResultView(uiconfig: UIConfig.default)
        view.configureRecipient(with: CardholderData(firstName: "Barak",
                                                     lastName: "Obama",
                                                     cardholderId: "crd_123445"),
                                contact: "+14047773234")
        
        view.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(414)
        }
        
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_recipientResultView_rendersViewWithNoResults() {
        let view = P2PRecipientResultView(uiconfig: UIConfig.default)
        view.showNoResults(with: "p2p_transfer.recipient_result_view.recipient_not_found.description".podLocalized())
        
        view.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(414)
        }
        
        assertSnapshot(matching: view, as: .image)
    }

}
