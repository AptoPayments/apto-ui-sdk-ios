//
//  UserStorageTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 20/08/2019.
//

import XCTest
@testable import AptoSDK
import SwiftyJSON

class UserStorageTest: XCTestCase {
  private var sut: UserStorage! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let transport = JSONTransportFake()
  private let apiKey = "api_key"
  private let userToken = "user_token"
  private let userData = ModelDataProvider.provider.emailDataPointList
  private let userJSON = ModelDataProvider.provider.userJSON

  override func setUp() {
    super.setUp()
    sut = UserStorage(transport: transport)
  }

  // MARK: - Create user
  func testCreateUserCallTransport() {
    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil, metadata: nil) { _ in }

    // Then
    XCTAssertTrue(transport.postCalled)
    XCTAssertNotNil(transport.lastPostURL)
    XCTAssertNotNil(transport.lastPostAuthorization)
    XCTAssertNotNil(transport.lastPostParameters)
    XCTAssertNotNil(transport.lastPostParameters?["data_points"])
    XCTAssertEqual(true, transport.lastPostFilterInvalidTokenResult)
  }

  func testCreateUserUsesAppropriateURL() {
    // Given
    let expectedUrl = JSONRouter.createUser

    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil, metadata: nil) { _ in }

    // Then
    guard let urlWrapper = transport.lastPostURL as? URLWrapper else {
      XCTFail("Wrong url type sent to transport")
      return
    }
    XCTAssertEqual(expectedUrl, urlWrapper.url)
  }

  func testCreateUserWithCustodianUidAddCustodianUidToParameters() {
    // Given
    let custodianUid = "custodianUid"

    // When
    sut.createUser(apiKey, userData: userData, custodianUid: custodianUid, metadata: nil) { _ in }

    // Then
    XCTAssertEqual(custodianUid, transport.lastPostParameters?["custodian_uid"] as? String)
  }

  func testCreateUserWithMetadataAddMetadataToParameters() {
    // Given
    let metadata = "metadata"

    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil, metadata: metadata) { _ in }

    // Then
    XCTAssertEqual(metadata, transport.lastPostParameters?["metadata"] as? String)
  }

  func testCreateUserRequestFailsCallbackFailure() {
    // Given
    var returnedResult: Result<ShiftUser, NSError>?
    transport.nextPostResult = .failure(BackendError(code: .emailInvalid))

    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil, metadata: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testCreateUserRequestSuccessCallbackSuccess() {
    // Given
    var returnedResult: Result<ShiftUser, NSError>?
    transport.nextPostResult = .success(userJSON)

    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil, metadata: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testCreateUserRequestSuccessWithMalformedJSONCallbackFailure() {
    // Given
    var returnedResult: Result<ShiftUser, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil, metadata: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  // MARK: - Fetch monthly statements period
  func testFetchStatementsPeriodCallTransport() {
    // When
    sut.fetchStatementsPeriod(apiKey, userToken: userToken) { _ in }

    // Then
    XCTAssertTrue(transport.getCalled)
    XCTAssertNotNil(transport.lastGetURL)
    XCTAssertNotNil(transport.lastGetAuthorization)
    XCTAssertNil(transport.lastGetParameters)
    XCTAssertEqual(true, transport.lastGetFilterInvalidTokenResult)
  }

  func testFetchStatementsPeriodWithAppropriateURL() {
    // Given
    let expectedUrl = JSONRouter.monthlyStatementsPeriod

    // When
    sut.fetchStatementsPeriod(apiKey, userToken: userToken) { _ in }

    // Then
    guard let urlWrapper = transport.lastGetURL as? URLWrapper else {
      XCTFail("Wrong url type sent to transport")
      return
    }
    XCTAssertEqual(expectedUrl, urlWrapper.url)
  }

  func testFetchStatementsPeriodRequestFailCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlyStatementsPeriod, NSError>?
    transport.nextGetResult = .failure(BackendError(code: .other))

    // When
    sut.fetchStatementsPeriod(apiKey, userToken: userToken) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testFetchStatementsPeriodRequestSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<MonthlyStatementsPeriod, NSError>?
    transport.nextGetResult = .success(ModelDataProvider.provider.monthlyStatementsPeriodJSON)

    // When
    sut.fetchStatementsPeriod(apiKey, userToken: userToken) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testFetchStatementsPeriodRequestSucceedWithMalformedJSONCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlyStatementsPeriod, NSError>?
    transport.nextGetResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.fetchStatementsPeriod(apiKey, userToken: userToken) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  // MARK: - Fetch monthly statement report
  func testFetchStatementCallTransport() {
    // When
    sut.fetchStatement(apiKey, userToken: userToken, month: 2, year: 2019) { _ in }

    // Then
    XCTAssertTrue(transport.postCalled)
    XCTAssertNotNil(transport.lastPostURL)
    XCTAssertNotNil(transport.lastPostAuthorization)
    XCTAssertNotNil(transport.lastPostParameters)
    XCTAssertEqual("2", transport.lastPostParameters?["month"] as? String)
    XCTAssertEqual("2019", transport.lastPostParameters?["year"] as? String)
    XCTAssertEqual(true, transport.lastPostFilterInvalidTokenResult)
  }

  func testFetchStatementWithAppropriateURL() {
    // Given
    let expectedUrl = JSONRouter.monthlyStatements

    // When
    sut.fetchStatement(apiKey, userToken: userToken, month: 2, year: 2019) { _ in }

    // Then
    guard let urlWrapper = transport.lastPostURL as? URLWrapper else {
      XCTFail("Wrong url type sent to transport")
      return
    }
    XCTAssertEqual(expectedUrl, urlWrapper.url)
  }

  func testFetchStatementRequestFailCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlyStatementReport, NSError>?
    transport.nextPostResult = .failure(BackendError(code: .other))

    // When
    sut.fetchStatement(apiKey, userToken: userToken, month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testFetchStatementRequestSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<MonthlyStatementReport, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.monthlyStatementReportJSON)

    // When
    sut.fetchStatement(apiKey, userToken: userToken, month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testFetchStatementRequestSucceedWithMalformedJSONCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlyStatementReport, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.fetchStatement(apiKey, userToken: userToken, month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  // MARK: - Start primary verification
  func testStartPrimaryVerificationCallTransport() {
    // When
    sut.startPrimaryVerification(apiKey, userToken: userToken) { _ in  }

    // Then
    XCTAssertTrue(transport.postCalled)
    XCTAssertNotNil(transport.lastPostURL)
    XCTAssertNotNil(transport.lastPostAuthorization)
    XCTAssertEqual(true, transport.lastPostFilterInvalidTokenResult)
  }

  func testStartPrimaryVerificationRequestFailCallbackFailure() {
    // Given
    var returnedResult: Result<Verification, NSError>?
    transport.nextPostResult = .failure(BackendError(code: .other))

    // When
    sut.startPrimaryVerification(apiKey, userToken: userToken) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testStartPrimaryVerificationRequestSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Verification, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.verificationJSON)

    // When
    sut.startPrimaryVerification(apiKey, userToken: userToken) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testStartPrimaryVerificationRequestSucceedWithMalformedJSONCallbackFailure() {
    // Given
    var returnedResult: Result<Verification, NSError>?
    transport.nextPostResult = .success(ModelDataProvider.provider.emptyJSON)

    // When
    sut.startPrimaryVerification(apiKey, userToken: userToken) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

}
