//
//  DirectDepositViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 27/1/21.
//

import XCTest
import SnapshotTesting
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class DirectDepositViewTests: XCTestCase {
    
    func test_infoView_rendersViewWithInfoAndValue() {
        let view = ShowInfoView(uiconfig: UIConfig.default)
        view.configure(with: "Bank Name", valueText: "Evolve Bank & Trust")
        view.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }

    func test_directDepositView_rendersViewWithInformation() {
        let view = DirectDepositView(uiconfig: UIConfig.default)
        let details = BankAccountDetails(routingNumber: "123000789", accountNumber: "1234567890")
        let viewData = DirectDepositViewData(accountDetails: details,
                                             description: "You can set up direct deposit online by entering this information into your payroll website, and your future paycheck will automatically deposit into your [appName] account.",
                                             footer: "The [appName] account is offered by Evolve Bank & Trust.")
        view.configure(with: viewData)
        view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }
}
