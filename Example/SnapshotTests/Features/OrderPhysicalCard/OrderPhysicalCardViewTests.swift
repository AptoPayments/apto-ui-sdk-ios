//
//  OrderPhysicalCardViewTests.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 23/3/21.
//

import XCTest
import SnapshotTesting
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class OrderPhysicalCardViewTests: XCTestCase {

    func test_orderPhysicalCardView_rendersView() {
        let view = OrderPhysicalCardView(uiconfig: UIConfig.default)
        let card = makeCard()
        view.configure(card: card, cardFee: "$9.95")
        
        view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }

    func test_orderPhysicalCardView_rendersViewWithoutFeeWhenFeeIsNotPreset() {
        let view = OrderPhysicalCardView(uiconfig: UIConfig.default)
        let card = makeCard()
        view.configure(card: card, cardFee: nil)
        
        view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_orderPhysicalCardView_rendersViewWithoutFeeWhenFeeIsZero() {
        let view = OrderPhysicalCardView(uiconfig: UIConfig.default)
        let card = makeCard()
        view.configure(card: card, cardFee: "$0.00")
        
        view.snp.makeConstraints { make in
            make.height.equalTo(896)
            make.width.equalTo(414)
        }
        assertSnapshot(matching: view, as: .image)
    }

    // MARK: Private methods
    private func makeCard() -> Card {
        return ModelDataProvider.provider.cardWithDataToRenderACreditCardView
    }
}
