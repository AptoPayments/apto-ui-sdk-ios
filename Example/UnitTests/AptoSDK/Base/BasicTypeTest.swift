//
//  BasicTypeTest.swift
//  UnitTests
//
//  Created by Evan Li on 10/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

@testable import AptoSDK
@testable import AptoUISDK

final class BasicTypeTest: XCTestCase {

  func test_valid_country_code() throws {
    let country = Country(isoCode: "US")
    XCTAssertEqual(country.name, "United States")
  }
  
  func test_invalid_country_code() throws {
    let country = Country(isoCode: "alv")
    XCTAssertEqual(country.name, "")
  }

}
