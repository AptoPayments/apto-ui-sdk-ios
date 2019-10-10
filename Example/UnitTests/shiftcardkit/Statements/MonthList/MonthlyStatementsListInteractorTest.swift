//
//  MonthlyStatementsListInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 23/09/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class MonthlyStatementsListInteractorTest: XCTestCase {
  private var sut: MonthlyStatementsListInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let platform = AptoPlatformFake()
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()
    sut = MonthlyStatementsListInteractor(platform: platform)
  }

  func testStatementsPeriodCallPlatform() {
    // When
    sut.fetchStatementsPeriod { _ in }

    // Then
    XCTAssertTrue(platform.fetchMonthlyStatementsPeriodCalled)
  }

  func testFetchStatementsSucceedCallSuccess() {
    // Given
    platform.nextFetchMonthlyStatementsPeriodResult = .success(dataProvider.monthlyStatementsPeriod)

    // When
    sut.fetchStatementsPeriod { result in
      // Then
      XCTAssertTrue(result.isSuccess)
    }
  }

  func testFetchStatementsFailsCallbackFailure() {
    // Given
    platform.nextFetchMonthlyStatementsPeriodResult = .failure(BackendError(code: .other))

    // When
    sut.fetchStatementsPeriod { result in
      // Then
      XCTAssertTrue(result.isFailure)
    }
  }

  func testStatementCallPlatform() {
    // When
    sut.fetchStatement(month: 2, year: 2019) { _ in }

    // Then
    XCTAssertTrue(platform.fetchMonthlyStatementReportCalled)
  }

  func testFetchStatementReportSucceedCallSuccess() {
    // Given
    platform.nextFetchMonthlyStatementReportResult = .success(dataProvider.monthlyStatementReport)

    // When
    sut.fetchStatement(month: 2, year: 2019) { result in
      // Then
      XCTAssertTrue(result.isSuccess)
    }
  }

  func testFetchStatementReportFailsCallbackFailure() {
    // Given
    platform.nextFetchMonthlyStatementReportResult = .failure(BackendError(code: .other))

    // When
    sut.fetchStatement(month: 2, year: 2019) { result in
      // Then
      XCTAssertTrue(result.isFailure)
    }
  }
}
