//
// CardWaitListInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

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
        XCTAssertTrue(platform.fetchCardCalled)
    }

    func testApplicationStatusFailCallbackFailure() {
        // Given
        var returnedResult: Result<Card, NSError>?
        platform.nextFetchCardResult = .failure(BackendError(code: .other))

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
        platform.nextFetchCardResult = .success(card)

        // When
        sut.reloadCard { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }
}
