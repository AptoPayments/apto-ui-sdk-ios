//
// CardWaitListModuleTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class CardWaitListModuleTest: XCTestCase {
  private var sut: CardWaitListModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let card = ModelDataProvider.provider.waitListedCard
  private let cardProduct = ModelDataProvider.provider.cardProduct
  private lazy var presenter = serviceLocator.presenterLocatorFake.cardWaitListPresenterSpy

  override func setUp() {
    super.setUp()

    sut = CardWaitListModule(serviceLocator: serviceLocator, card: card, cardProduct: cardProduct)
  }

  func testInitializeCallbackSuccess() {
    // Given
    var returnedResult: Result<UIViewController, NSError>?

    // When
    sut.initialize { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testInitializeSetUpPresenter() {
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.router)
  }

  func testApplicationStatusChangedCallOnFinish() {
    // Given
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    sut.cardStatusChanged()

    // Then
    XCTAssertTrue(onFinishCalled)
  }
}
