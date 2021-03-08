//
//  FinancialAccountsStorageTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 20/08/2019.
//

import XCTest
import Alamofire
import SwiftyJSON
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
    var returnedResult: Swift.Result<MonthlySpending, NSError>?
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
    var returnedResult: Swift.Result<MonthlySpending, NSError>?
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
    var returnedResult: Swift.Result<MonthlySpending, NSError>?
    transport.nextGetResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.fetchMonthlySpending(apiKey, userToken: userToken, accountId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  // MARK: - Set card pass code
  func testSetCardPassCodeCallTransport() {
    // When
    sut.setCardPassCode(apiKey, userToken: userToken, cardId: "card_id", passCode: "passcode",
                        verificationId: "verification_id") { _ in }

    // Then
    XCTAssertTrue(transport.postCalled)
    XCTAssertNotNil(transport.lastPostURL)
    XCTAssertNotNil(transport.lastPostAuthorization)
    XCTAssertNotNil(transport.lastPostParameters)
    XCTAssertNotNil(transport.lastPostParameters?["passcode"])
    XCTAssertNotNil(transport.lastPostParameters?["verification_id"])
    XCTAssertEqual(true, transport.lastPostFilterInvalidTokenResult)
  }

  func testSetCardPassCodeWithAppropriateURL() {
    // Given
    let expectedUrl = JSONRouter.setCardPassCode

    // When
    sut.setCardPassCode(apiKey, userToken: userToken, cardId: "card_id", passCode: "passcode") { _ in }

    // Then
    guard let urlWrapper = transport.lastPostURL as? URLWrapper else {
      XCTFail("Wrong url type sent to transport")
      return
    }
    XCTAssertEqual(expectedUrl, urlWrapper.url)
  }

  func testSetCardPassCodeRequestFailCallbackFailure() {
    // Given
    var returnedResult: Swift.Result<Void, NSError>?
    transport.nextPostResult = .failure(BackendError(code: .other))

    // When
    sut.setCardPassCode(apiKey, userToken: userToken, cardId: "card_id", passCode: "passcode") { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testSetCardPassCodeRequestSucceedCallbackSuccess() {
    // Given
    var returnedResult: Swift.Result<Void, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.setCardPassCode(apiKey, userToken: userToken, cardId: "card_id", passCode: "passcode") { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
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
    var returnedResult: Swift.Result<Card, NSError>?
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
    var returnedResult: Swift.Result<Card, NSError>?
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
    var returnedResult: Swift.Result<Card, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                  additionalFields: additionalFields, initialFundingSourceId: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
    
    func test_getFinancialAccount_deliversAccountDetailsOnValidJSONResponse() throws {
        let accountId = "crd_98hnhu9sc7i9ay73375"
        let (sut, transport) = makeSUT()
        let item = makeCardInfo()
        
        let exp = expectation(description: "Wait for completion")
        var capturedResults: Swift.Result<FinancialAccount, NSError>?
        sut.getFinancialAccount(apiKey,
                                userToken: userToken,
                                accountId: accountId,
                                forceRefresh: true,
                                retrieveBalances: false,
                                callback: { result in
                                    capturedResults = result
                                    exp.fulfill()
                                })
        
        transport.complete(withResult: item.json)

        guard let result = try? capturedResults?.get(), let card = result as? Card else {
            XCTFail("Expected success got failure")
            return
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(card.features?.achAccount?.status, item.card.features?.achAccount?.status)
    }

    // MARK: Private Helper methods
    private func makeSUT() -> (sut: FinancialAccountsStorage, transport: StorageTransportSpy) {
        let transport = StorageTransportSpy()
        let cache = FinancialAccountCache(localCacheFileManager: LocalCacheFileManagerSpy())
        let sut = FinancialAccountsStorage(transport: transport, cache: cache)
        return (sut, transport)
    }
    
    private func makeCardInfo() -> (card: Card, json: JSON) {
        
        let card = ModelDataProvider.provider.cardWithACHAccount
        let jsonDetails: JSON = [
            "type": "card",
            "account_id": "card_id",
            "last_four": "7890",
            "card_network": "VISA",
            "card_brand": "Marvel Card",
            "card_issuer": "shift",
            "expiration": "2021-03",
            "state": "active",
            "kyc_status": "PASSED",
            "kyc_reason": "reason",
            "ordered_status": "ordered",
            "cardholder_first_name": "Holder",
            "cardholder_last_name": "Name",
            "card_product_id": "card_product_id",
            "features": [
                "ach": [
                    "status": "enabled",
                    "account_provisioned": false,
                    "disclaimer": [
                            "agreement_keys": [
                                "evolve_eua"
                            ],
                            "content": [
                                "type": "content",
                                "format": "external_url",
                                "value": "http://agreements.com"
                            ]
                    ],
                    "account_details": [
                        "routing_number": "123000789",
                        "account_number": "1234567890"
                    ]
                ]
            ]
        ]
        return (card, jsonDetails)
    }
    
    class LocalCacheFileManagerSpy: LocalCacheFileManagerProtocol {
        var cache = [String: Data]()
        
        func write(data: Data, filename: String) throws {
            cache[filename] = data
        }
        
        func read(filename: String) throws -> Data? {
            cache[filename]
        }
        
        func invalidate() throws {
            cache.removeAll()
        }
    }

}
