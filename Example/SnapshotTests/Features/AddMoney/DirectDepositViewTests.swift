//
//  DirectDepositViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 27/1/21.
//

import SnapKit
import SnapshotTesting
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class DirectDepositViewTests: XCTestCase {
    func test_infoView_rendersViewWithInfoAndValue() {
        let view = ShowInfoView(uiconfig: UIConfig.default)
        view.configure(with: "Bank Name", valueText: "Evolve Bank & Trust")
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }

    func test_directDepositView_rendersViewWithInformation() {
        let view = DirectDepositView(uiconfig: UIConfig.default)
        let details = ACHAccountDetails(routingNumber: "123000789", accountNumber: "1234567890")
        let viewData = DirectDepositViewData(accountDetails: details,
                                             description: "Login to your external account to submit a direct deposit account request or ACH bank transfer. You'll need the information below to complete the set up:",
                                             footer: "The [appName] account is offered by Evolve Bank & Trust.")
        view.configure(with: viewData)
        let vc = HostViewController(with: view)

        vc.view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }

        assertSnapshot(matching: vc, as: .image(on: .iPhoneSe))
    }
}
