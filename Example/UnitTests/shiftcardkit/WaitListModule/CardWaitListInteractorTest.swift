//
// CardWaitListInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class CardWaitListInteractorTest: XCTestCase {
  private var sut: CardWaitListInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let card = ModelDataProvider.provider.card
  private lazy var platform = ServiceLocatorFake().platformFake

  override func setUp() {
    super.setUp()

    sut = CardWaitListInteractor(platform: platform, card: card)
  }

  func testReloadCardCallCardSession() {
    // When
    sut.reloadCard { _ in }

    // Then
    XCTAssertTrue(platform.fetchFinancialAccountCalled)
  }

  func testApplicationStatusFailCallbackFailure() {
    // Given
    var returnedResult: Result<Card, NSError>?
    platform.nextFetchFinancialAccountResult = .failure(BackendError(code: .other))

    // When
    sut.reloadCard { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testApplicationStatusSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Card, NSError>?
    platform.nextFetchFinancialAccountResult = .success(card)

    // When
    sut.reloadCard { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }
}
