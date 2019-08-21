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
  private let balanceVersion = BalanceVersion.v2
  private let additionalFields: [String: AnyObject] = [
    "field1": "field1 value" as AnyObject,
    "nestedField": [
      "nestedField1": "nestedField1 value" as AnyObject
    ] as AnyObject,
    "field2": 3 as AnyObject
  ]

  override func setUp() {
    super.setUp()
    sut = FinancialAccountsStorage(transport: transport, cache: cache)
  }

  func testIssueCardCallTransport() {
    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  balanceVersion: balanceVersion, additionalFields: nil) { _ in }

    // Then
    XCTAssertTrue(transport.postCalled)
    XCTAssertNotNil(transport.lastPostURL)
    XCTAssertNotNil(transport.lastPostAuthorization)
    XCTAssertNotNil(transport.lastPostParameters)
    XCTAssertNotNil(transport.lastPostParameters?["card_product_id"])
    XCTAssertNotNil(transport.lastPostParameters?["balance_version"])
    XCTAssertEqual("v2", transport.lastPostParameters?["balance_version"] as? String)
    XCTAssertNil(transport.lastPostParameters?["additional_fields"])
    XCTAssertEqual(true, transport.lastPostFilterInvalidTokenResult)
  }

  func testIssueCardWithAppropriateURL() {
    // Given
    let expectedUrl = JSONRouter.issueCard

    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  balanceVersion: balanceVersion, additionalFields: additionalFields) { _ in }

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
                  balanceVersion: balanceVersion, additionalFields: additionalFields) { _ in }

    // Then
    XCTAssertNotNil(transport.lastPostParameters?["additional_fields"])
  }

  func testIssueCardRequestFailCallbackFailure() {
    // Given
    var returnedResult: Result<Card, NSError>?
    transport.nextPostResult = .failure(BackendError(code: .other))

    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  balanceVersion: balanceVersion, additionalFields: additionalFields) { result in
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
                  balanceVersion: balanceVersion, additionalFields: additionalFields) { result in
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
                  balanceVersion: balanceVersion, additionalFields: additionalFields) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
}
