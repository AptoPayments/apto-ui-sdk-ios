//
//  P2PTransferFundsViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 10/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SnapKit

@testable import AptoUISDK
@testable import AptoSDK

class P2PTransferFundsViewControllerTests: XCTestCase {

    private let cardId = "crd_123456789"
    
    func test_init_rendersP2PTransferFundsView() throws {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.view)
        XCTAssertTrue(sut.view.subviews.count > 0)
        XCTAssertTrue(((sut.view.subviews.first?.isKind(of: P2PTransferFundsView.self)) != nil))
    }

    func test_init_doesNotFetchFundingSource() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.fetchFundingSourceLoadCallCount, 0)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_viewDidLoad_loadsFetchFundingSource() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.fetchFundingSourceLoadCallCount, 1)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_loadFetchFundingSource_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isActivityIndicatorLoading)
    }

    func test_loadFetchFundingSource_hidesLoadingIndicator() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFundingSource()

        XCTAssertTrue(sut.isActivityIndicatorHidden)
    }
    
    func test_validAmount_performTransferRequest() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFundingSource()

        sut.amountTextField.becomeFirstResponder()
        sut.amountTextField.text = "10"
        sut.amountTextField.simulate(event: UIControl.Event.editingChanged)
        sut.completTransferButton.simulateTap()
        
        XCTAssertEqual(loader.fetchFundingSourceLoadCallCount, 1)
        XCTAssertEqual(loader.transferLoadCallCount, 1)
    }

    func test_invalidAmount_doesNotShowActionButton() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFundingSource()

        sut.amountTextField.becomeFirstResponder()
        sut.amountTextField.text = "0"
        sut.amountTextField.simulate(event: UIControl.Event.editingChanged)
        
        XCTAssertEqual(loader.fetchFundingSourceLoadCallCount, 1)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
        XCTAssertTrue(sut.completTransferButton.isHidden)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: P2PTransferFundsViewController, loader: P2PTransferLoaderSpy) {
        let loader = P2PTransferLoaderSpy()
        let viewModel = P2PTransferFundsViewModel(loader: loader, cardId: cardId)
        let transferModel = P2PTransferModel(phone: PhoneNumber(countryCode: 1, phoneNumber: "4047771234"),
                                             email: nil,
                                             cardholder: CardholderData(firstName: "James", lastName: "Logan", cardholderId: "crdhldr_9f8d908943a0dca17244"))
        let sut = P2PTransferFundsViewController(uiConfiguration: UIConfig.default, viewModel: viewModel, transferModel: transferModel)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

}

private extension P2PTransferFundsViewController {
    var isActivityIndicatorLoading: Bool {
        if let window = UIApplication.shared.keyWindow {
            if let view = window.viewWithTag(2020),
               let firstView = view.subviews.first,
               let spinner = firstView as? UIActivityIndicatorView {
                return spinner.isAnimating
            }
        }
        return false
    }
    
    var isActivityIndicatorHidden: Bool {
        if let window = UIApplication.shared.keyWindow {
            let subviews = window.subviews.reversed()
            if let spinner = subviews.first {
                return spinner.alpha == 0
            }
        }
        return false
    }
    
    var amountTextField: UITextField {
        transferFundsView.amountTextField
    }
    
    var completTransferButton: UIButton {
        transferFundsView.actionButton
    }
}
