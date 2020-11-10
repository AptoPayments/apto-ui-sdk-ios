import XCTest

@testable import AptoUISDK

final class ExpirationDateValidatorTest: XCTestCase {

  let sut = ExpirationDateValidator()

  func test_validate_invalid_expiration_date_returns_false() {
    let expirationDate = "01-2020"

    XCTAssertFalse(sut.validate(expirationDate))
  }

  func test_validate_valid_expiration_date_four_digits_year_returns_true() {
    let expirationDate = "01/2020"

    XCTAssertTrue(sut.validate(expirationDate))
  }

  func test_validate_valid_expiration_date_two_digits_year_returns_true() {
    let expirationDate = "01/20"

    XCTAssertTrue(sut.validate(expirationDate))
  }

  func test_extract_date_invalid_expiration_date_returns_nil() {
    let expirationDate = "01-2020"

    XCTAssertNil(sut.extractDate(from: expirationDate))
  }

  func test_extract_date_valid_expiration_date_four_digits_returns_month_and_year() {
    let expirationDate = "01/2022"

    guard let (month, year) = sut.extractDate(from: expirationDate) else {
      XCTFail()
      return
    }
    XCTAssertEqual(month, 1)
    XCTAssertEqual(year, 2022)
  }

  func test_extract_date_valid_expiration_date_two_digits_returns_month_and_year() {
    let expirationDate = "01/22"

    guard let (month, year) = sut.extractDate(from: expirationDate) else {
      XCTFail()
      return
    }
    XCTAssertEqual(month, 1)
    XCTAssertEqual(year, 2022)
  }

}
