//
//  ApplePayButtonTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 14/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SnapshotTesting
import SnapKit
import AptoUISDK

@testable import AptoSDK

class ApplePayButtonTests: XCTestCase {

    func test_applePayButton_rendersView() {
        let helper = InAppProvisioningHelper()
        let buttonView = helper.appleWalletButton()
        
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(buttonView)
        
        buttonView.snp.makeConstraints { $0.center.equalToSuperview() }
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        
        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
