//
// SetPinInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/06/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class SetPinInteractorTest: XCTestCase {
  private var sut: SetPinInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var platform = serviceLocator.platformFake
  private let card = ModelDataProvider.provider.card
  private let pin = "0876"

  override func setUp() {
    super.setUp()
    sut = SetPinInteractor(platform: platform, card: card)
  }

  func testChangePinCallCardSessionToChangePin() {
    // When
    sut.changePin(pin) { _ in }

    // Then
    XCTAssertTrue(platform.changeCardPINCalled)
    XCTAssertEqual(card.accountId, platform.lastChangeCardPINCardId)
    XCTAssertEqual(pin, platform.lastChangeCardPINPIN)
  }

  func testChangePinSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Card, NSError>?
    platform.nextChangeCardPINResult = .success(card)

    // When
    sut.changePin(pin) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testChangePinFailsCallbackFailure() {
    // Given
    var returnedResult: Result<Card, NSError>?
    platform.nextChangeCardPINResult = .failure(BackendError(code: .other))

    // When
    sut.changePin(pin) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
}
