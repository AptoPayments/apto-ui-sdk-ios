//
//  FinancialAccountsStorageTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 20/08/2019.
//

import XCTest
@testable import AptoSDK

class FinancialAccountsStorageTest: XCTestCase {
  private var sut: FinancialAccountsStorage! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let transport = JSONTransportFake()
  private let cache = FinancialAccountCache(localCacheFileManager: LocalCacheFileManager())
  private let apiKey = "api_key"
  private let userToken = "user_token"
  private let cardProduct = ModelDataProvider.provider.cardProduct
  private let custodian = ModelDataProvider.provider.custodian
  private let additionalFields: [String: AnyObject] = [
    "field1": "field1 value" as AnyObject,
    "nestedField": [
      "nestedField1": "nestedField1 value" as AnyObject
    ] as AnyObject,
    "field2": 3 as AnyObject
  ]
  private let initialFundingSourceId = "initial_funding_source_id"

  override func setUp() {
    super.setUp()
    sut = FinancialAccountsStorage(transport: transport, cache: cache)
  }

  // MARK: - Fetch monthly spending
  func testFetchMonthlySpendingCallTransport() {
    // When
    sut.fetchMonthlySpending(apiKey, userToken: userToken, accountId: "card_id", month: 2, year: 2019) { _ in }

    // Then
    XCTAssertTrue(transport.getCalled)
    XCTAssertNotNil(transport.lastGetURL)
    XCTAssertNil(transport.lastGetHeaders)
    XCTAssertNotNil(transport.lastGetAuthorization)
    XCTAssertNil(transport.lastGetParameters)
    XCTAssertEqual(true, transport.lastGetFilterInvalidTokenResult)
  }

  func testFetchMonthlySpendingWithAppropriateURL() {
    // Given
    let expectedUrl = JSONRouter.financialAccountMonthlySpending

    // When
    sut.fetchMonthlySpending(apiKey, userToken: userToken, accountId: "card_id", month: 2, year: 2019) { _ in }

    // Then
    guard let urlWrapper = transport.lastGetURL as? URLWrapper else {
      XCTFail("Wrong url type sent to transport")
      return
    }
    XCTAssertEqual(expectedUrl, urlWrapper.url)
  }

  func testFetchMonthlySpendingRequestFailCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlySpending, NSError>?
    transport.nextGetResult = .failure(BackendError(code: .other))

    // When
    sut.fetchMonthlySpending(apiKey, userToken: userToken, accountId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testFetchMonthlySpendingRequestSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<MonthlySpending, NSError>?
    transport.nextGetResult = .success(ModelDataProvider.provider.monthlySpendingJSON)

    // When
    sut.fetchMonthlySpending(apiKey, userToken: userToken, accountId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testFetchfetchMonthlySpendingRequestSucceedWithMalformedJSONCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlySpending, NSError>?
    transport.nextGetResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.fetchMonthlySpending(apiKey, userToken: userToken, accountId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  // MARK: - Issue card
  func testIssueCardCallTransport() {
    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian, additionalFields: nil,
                  initialFundingSourceId: nil) { _ in }

    // Then
    XCTAssertTrue(transport.postCalled)
    XCTAssertNotNil(transport.lastPostURL)
    XCTAssertNotNil(transport.lastPostAuthorization)
    XCTAssertNotNil(transport.lastPostParameters)
    XCTAssertNotNil(transport.lastPostParameters?["card_product_id"])
    XCTAssertNil(transport.lastPostParameters?["additional_fields"])
    XCTAssertEqual(true, transport.lastPostFilterInvalidTokenResult)
  }

  func testIssueCardWithAppropriateURL() {
    // Given
    let expectedUrl = JSONRouter.issueCard

    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  additionalFields: additionalFields, initialFundingSourceId: nil) { _ in }

    // Then
    guard let urlWrapper = transport.lastPostURL as? URLWrapper else {
      XCTFail("Wrong url type sent to transport")
      return
    }
    XCTAssertEqual(expectedUrl, urlWrapper.url)
  }

  func testIssueCardWithAdditionalFieldsAddAdditionalFieldsToParameters() {
    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  additionalFields: additionalFields, initialFundingSourceId: nil) { _ in }

    // Then
    XCTAssertNotNil(transport.lastPostParameters?["additional_fields"])
  }

  func testIssueCardWithInitialFundingSourceIdAddInitialFundingSourceIdToParameters() {
    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  additionalFields: additionalFields, initialFundingSourceId: initialFundingSourceId) { _ in }

    // Then
    XCTAssertNotNil(transport.lastPostParameters?["initial_funding_source_id"])
  }

  func testIssueCardRequestFailCallbackFailure() {
    // Given
    var returnedResult: Result<Card, NSError>?
    transport.nextPostResult = .failure(BackendError(code: .other))

    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  additionalFields: additionalFields, initialFundingSourceId: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testIssueCardRequestSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Card, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.cardJSON)

    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  additionalFields: additionalFields, initialFundingSourceId: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testIssueCardRequestSucceedWithMalformedJSONCallbackFailure() {
    // Given
    var returnedResult: Result<Card, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  additionalFields: additionalFields, initialFundingSourceId: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
}
