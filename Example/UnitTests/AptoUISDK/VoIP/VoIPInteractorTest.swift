//
// VoIPInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/06/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class VoIPInteractorTest: XCTestCase {
  private var sut: VoIPInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let card = ModelDataProvider.provider.card
  private let actionSource = VoIPActionSource.getPin
  private lazy var platform = serviceLocator.platformFake

  override func setUp() {
    super.setUp()
    sut = VoIPInteractor(platform: platform, card: card, actionSource: actionSource)
  }

  func testFetchVoIPTokenCallSession() {
    // When
    sut.fetchVoIPToken { _ in }

    // Then
    XCTAssertTrue(platform.fetchVoIPTokenCalled)
    XCTAssertEqual(card.accountId, platform.lastFetchVoIPTokenCardId)
  }

  func testFetchVoIPSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<VoIPToken, NSError>?
    platform.nextFetchVoIPTokenResult = .success(ModelDataProvider.provider.voIPToken)

    // When
    sut.fetchVoIPToken { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testFetchVoIPFailsCallbackFailure() {
    // Given
    var returnedResult: Result<VoIPToken, NSError>?
    platform.nextFetchVoIPTokenResult = .failure(BackendError(code: .other))

    // When
    sut.fetchVoIPToken { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
}
