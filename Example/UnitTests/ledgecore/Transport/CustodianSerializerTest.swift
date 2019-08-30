//
//  CustodianSerializerTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/07/2019.
//

import XCTest
@testable import AptoSDK

class CustodianSerializerTest: XCTestCase {
  func testSerializeNil() {
    // Given
    let sut = Custodian(custodianType: "uphold", name: nil)
    sut.externalCredentials = nil
    let expectedJson = [
      "balance_store": [
        "type": "custodian",
        "custodian_type": "uphold"
      ]
    ]

    // When
    let json = sut.asJson

    // Then
    XCTAssertEqual(expectedJson, json as! [String: [String: String]])
  }

  func testSerializeOauthCredential() {
    // Given
    let sut = Custodian(custodianType: "coinbase", name: nil)
    sut.externalCredentials = .oauth(OauthCredential(oauthTokenId: "oauth_token_id"))
    let expectedJson = ["oauth_token_id": "oauth_token_id"]

    // When
    let json = sut.asJson

    // Then
    XCTAssertEqual(expectedJson, json as! [String: String])
  }

  func testSerializeOauthNone() {
    // Given
    let sut = Custodian(custodianType: "coinbase", name: nil)
    sut.externalCredentials = ExternalCredential.none

    // When
    var json = sut.asJson

    // Then
    XCTAssertEqual(1, json.count)
    XCTAssertEqual(3, (json["balance_store"]! as AnyObject as! [String: AnyObject]).count)
    XCTAssertEqual("custodian", json["balance_store"]!["type"]! as AnyObject as! String)
    XCTAssertEqual("coinbase", json["balance_store"]!["custodian_type"]! as AnyObject as! String)
    XCTAssertTrue((json["balance_store"]!["credential"]! as AnyObject as! [String: String]).isEmpty)
  }

  func testSerializeExternalOauthCredential() {
    // Given
    let sut = Custodian(custodianType: "coinbase", name: nil)
    sut.externalCredentials = .externalOauth(ExternalOauthCredential(oauthToken: "token", refreshToken: "refresh"))
    let expectedCredential = [
      "access_token": "token",
      "refresh_token": "refresh",
      "credential_type": "oauth",
      "type": "credential"
    ]

    // When
    var json = sut.asJson

    // Then
    XCTAssertEqual(1, json.count)
    XCTAssertEqual(3, (json["balance_store"]! as AnyObject as! [String: AnyObject]).count)
    XCTAssertEqual("custodian", json["balance_store"]!["type"]! as AnyObject as! String)
    XCTAssertEqual("coinbase", json["balance_store"]!["custodian_type"]! as AnyObject as! String)
    XCTAssertEqual(expectedCredential, json["balance_store"]!["credential"]! as AnyObject as! [String: String])
  }
}
