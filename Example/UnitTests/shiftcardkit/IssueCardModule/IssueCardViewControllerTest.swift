//
//  IssueCardViewControllerTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class IssueCardViewControllerTest: XCTestCase {
  private var sut: IssueCardViewControllerTheme1! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private lazy var dataProvider = ModelDataProvider.provider
  private lazy var uiConfig = dataProvider.uiConfig
  private lazy var eventHandler = IssueCardPresenterSpy()

  override func setUp() {
    super.setUp()

    sut = IssueCardViewControllerTheme1(uiConfiguration: uiConfig, eventHandler: eventHandler)
  }

  func testViewDidLoadNotifyEventHandler() {
    // When
    sut.viewDidLoad()

    // Then
    XCTAssertTrue(eventHandler.viewLoadedCalled)
  }
}
