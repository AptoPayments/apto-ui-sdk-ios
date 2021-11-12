//
//  GenericResultScreenViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 4/8/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SnapshotTesting
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class GenericResultScreenViewTests: XCTestCase {

    func test_genericResultView_rendersViewForSuccess() {
        let view = GenericResultScreenView(uiconfig: UIConfig.default)
        view.configure(for: .success, text: "This is a success result screen!")
        
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        
        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }

    func test_genericResultViewWithBottomItems_rendersViewWithBottomItemsForSuccess() {
        let view = GenericResultScreenView(uiconfig: UIConfig.default, bottomViewItemCount: 2)
        view.configure(for: .success, text: "This is a success result screen!")
        view.configureBottomItems(with: [
            BottomItemModel(info: "Status", value: "Completed"),
            BottomItemModel(info: "Time", value: "June 25, 2020 9:30 am"),
        ])
        
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        
        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }

}
