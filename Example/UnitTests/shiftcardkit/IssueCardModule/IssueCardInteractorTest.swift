//
//  IssueCardInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class IssueCardInteractorTest: XCTestCase {
  private var sut: IssueCardInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  //Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var platform = serviceLocator.platformFake
  private lazy var dataProvider = ModelDataProvider.provider
  private lazy var application: CardApplication = dataProvider.cardApplication
  private lazy var cardAdditionalFieldsSpy = CardAdditionalFieldsSpy()

  override func setUp() {
    super.setUp()

    sut = IssueCardInteractor(
      platform: platform,
      application: application,
      cardAdditionalFields: cardAdditionalFieldsSpy,
        initializationData: ModelDataProvider.provider.initializationData
    )
  }

  func testIssueCardCalledCallSessionToIssueCard() {
    // When
    sut.issueCard() { _ in }

    // Then
    XCTAssertTrue(platform.issueCardCalled)
    XCTAssertEqual(platform.lastIssueCardApplicationId, application.id)
  }
  
  func testGetStoredAdditionalFieldsWhenIssueCard() {
    // When
    sut.issueCard { _ in }
    
    // Then
    XCTAssertTrue(cardAdditionalFieldsSpy.getCalled)
  }

  func testIssueCardFailureCallbackError() {
    // Given
    let error = BackendError(code: .undefinedError)
    platform.nextIssueCardResult = .failure(error)

    // When
    var result: Result<Card, NSError>?
    sut.issueCard { returnedResult in
      result = returnedResult
    }

    // Then
    XCTAssertTrue(result!.isFailure) // swiftlint:disable:this force_unwrapping
  }

  func testIssueCardSucceedCallbackSuccess() {
    // Given
    let card = dataProvider.card
    platform.nextIssueCardResult = .success(card)

    // When
    var result: Result<Card, NSError>?
    sut.issueCard { returnedResult in
      result = returnedResult
    }

    // Then
    XCTAssertTrue(result!.isSuccess) // swiftlint:disable:this force_unwrapping
  }
}
