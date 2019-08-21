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
  private let userData = ModelDataProvider.provider.emailDataPointList
  private let userJSON = ModelDataProvider.provider.userJSON

  override func setUp() {
    super.setUp()
    sut = UserStorage(transport: transport)
  }

  func testCreateUserCallTransport() {
    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil) { _ in }

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
    sut.createUser(apiKey, userData: userData, custodianUid: nil) { _ in }

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
    sut.createUser(apiKey, userData: userData, custodianUid: custodianUid) { _ in }

    // Then
    XCTAssertEqual(custodianUid, transport.lastPostParameters?["custodian_uid"] as? String)
  }

  func testCreateUserRequestFailsCallbackFailure() {
    // Given
    var returnedResult: Result<ShiftUser, NSError>?
    transport.nextPostResult = .failure(BackendError(code: .emailInvalid))

    // When
    sut.createUser(apiKey, userData: userData, custodianUid: nil) { result in
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
    sut.createUser(apiKey, userData: userData, custodianUid: nil) { result in
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
    sut.createUser(apiKey, userData: userData, custodianUid: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
}
