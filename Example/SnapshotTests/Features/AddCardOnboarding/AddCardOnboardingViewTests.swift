//
//  AddCardOnboardingViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 15/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SnapKit
import SnapshotTesting
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class AddCardOnboardingViewTests: XCTestCase {
    func test_addOnboardingView_rendersViewWithInformation() {
        let view = AddCardOnboardingView(uiconfig: UIConfig.default)
        view.configure(firstParagraph: "You can instantly transfer funds from your existing bank debit card to your <<VALUE>> card account. Please note that transfers are reviewed and they can be delayed or declined if we suspect risks.",
                       secondParagraph: "This transaction will appear in your bank account statement as: <<VALUE>>")
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
