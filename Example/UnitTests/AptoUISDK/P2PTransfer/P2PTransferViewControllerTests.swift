//
//  P2PTransferViewControllerTests.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 28/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SnapKit
import XCTest

@testable import AptoSDK
@testable import AptoUISDK

class P2PTransferViewControllerTests: XCTestCase {
    func test_init_rendersP2PTransferView() throws {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view)
        XCTAssertTrue(sut.view.subviews.count > 0)
        XCTAssertTrue((sut.view.subviews.first?.isKind(of: P2PTransferView.self)) != nil)
    }

    func test_init_doesNotFetchConfiguration() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.fetchConfigurationLoadCallCount, 0)
        XCTAssertEqual(loader.findRecipientLoadCallCount, 0)
        XCTAssertEqual(loader.inviteLoadCallCount, 0)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_viewDidLoad_loadsFetchConfiguration() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.fetchConfigurationLoadCallCount, 1)
        XCTAssertEqual(loader.findRecipientLoadCallCount, 0)
        XCTAssertEqual(loader.inviteLoadCallCount, 0)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_loadFetchConfiguration_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isActivityIndicatorLoading)
    }

    func test_loadFetchConfiguration_hidesLoadingIndicator() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeConfiguration()

        XCTAssertFalse(sut.isActivityIndicatorLoading)
    }

    func test_invalidPhoneNumber_doesNotPerformFindRecipientRequest() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        sut.phoneNumberTextField.becomeFirstResponder()
        sut.phoneNumberTextField.text = "+123456789"
        sut.phoneNumberTextField.simulate(event: UIControl.Event.editingChanged)

        XCTAssertEqual(loader.fetchConfigurationLoadCallCount, 1)
        XCTAssertEqual(loader.findRecipientLoadCallCount, 0)
        XCTAssertEqual(loader.inviteLoadCallCount, 0)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_validPhoneNumber_performFindRecipientRequest() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        sut.phoneNumberTextField.becomeFirstResponder()
        sut.phoneNumberTextField.text = "+14047772365"
        sut.phoneNumberTextField.simulate(event: UIControl.Event.editingChanged)

        XCTAssertEqual(loader.fetchConfigurationLoadCallCount, 1)
        XCTAssertEqual(loader.findRecipientLoadCallCount, 1)
        XCTAssertEqual(loader.inviteLoadCallCount, 0)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_invalidPhoneNumber_rendersTextFieldAsInvalid() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        sut.phoneNumberTextField.becomeFirstResponder()
        sut.phoneNumberTextField.text = "+123456789"
        sut.phoneNumberTextField.sendActions(for: UIControl.Event.editingChanged)

        XCTAssertTrue(sut.phoneNumberIsInvalid)
    }

    func test_invalidEmail_doesNotPerformFindRecipientRequest() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        sut.emailTextField.becomeFirstResponder()
        sut.emailTextField.text = "barak@gmail"
        sut.emailTextField.simulate(event: UIControl.Event.editingChanged)

        XCTAssertEqual(loader.fetchConfigurationLoadCallCount, 1)
        XCTAssertEqual(loader.findRecipientLoadCallCount, 0)
        XCTAssertEqual(loader.inviteLoadCallCount, 0)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_validEmail_performFindRecipientRequest() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        sut.emailTextField.becomeFirstResponder()
        sut.emailTextField.text = "barak@gmail.com"
        sut.emailTextField.simulate(event: UIControl.Event.editingChanged)

        XCTAssertEqual(loader.fetchConfigurationLoadCallCount, 1)
        XCTAssertEqual(loader.findRecipientLoadCallCount, 1)
        XCTAssertEqual(loader.inviteLoadCallCount, 0)
        XCTAssertEqual(loader.transferLoadCallCount, 0)
    }

    func test_invalidEmail_rendersTextFieldAsInvalid() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        sut.emailTextField.becomeFirstResponder()
        sut.emailTextField.text = "barak@gmail"
        sut.emailTextField.simulate(event: UIControl.Event.editingChanged)

        XCTAssertTrue(sut.emailIsInvalid)
    }

    func test_notExistentPhoneNumber_showsNoResultView() {
        let (sut, loader) = makeSUT()
        let error = NSError(domain: "com.aptopayments.aptocard", code: 404, userInfo: ["message": "user_not_found"])

        sut.loadViewIfNeeded()

        sut.phoneNumberTextField.becomeFirstResponder()
        sut.phoneNumberTextField.text = "+14047772666"
        sut.phoneNumberTextField.simulate(event: UIControl.Event.editingChanged)

        loader.completeFindRecipient(with: error)

        XCTAssertTrue(sut.showNoResultsView)
    }

    func test_existingPhoneNumber_doesNotShowNoResultView() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        sut.phoneNumberTextField.becomeFirstResponder()
        sut.phoneNumberTextField.text = "+14047772666"
        sut.phoneNumberTextField.simulate(event: UIControl.Event.editingChanged)

        loader.completeFindRecipient(with: ModelDataProvider.provider.recipient)

        XCTAssertFalse(sut.showNoResultsView)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: P2PTransferViewController, loader: P2PTransferLoaderSpy) {
        let loader = P2PTransferLoaderSpy()
        let viewModel = P2PTransferViewModel(loader: loader)
        let sut = P2PTransferViewController(uiConfiguration: UIConfig.default, viewModel: viewModel, projectConfiguration: nil)
        sut.debounceDelay = 0
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
}

private extension P2PTransferViewController {
    var isActivityIndicatorLoading: Bool {
        return activityIndicator.isAnimating
    }

    var phoneNumberTextField: UITextField {
        return transferView.phoneTextField
    }

    var emailTextField: UITextField {
        return transferView.emailTextField
    }

    var phoneNumberIsInvalid: Bool {
        return transferView.phoneTextField.textColor == uiConfiguration.uiErrorColor
    }

    var emailIsInvalid: Bool {
        return transferView.emailTextField.textColor == uiConfiguration.uiErrorColor
    }

    var showNoResultsView: Bool {
        return transferView.resultsView.emptyLabel.alpha == 1
    }
}
