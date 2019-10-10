//
//  MonthlyStatementsReportModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class MonthlyStatementsReportModuleTest: XCTestCase {
  private var sut: MonthlyStatementsReportModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let statementReport = ModelDataProvider.provider.monthlyStatementReport

  override func setUp() {
    super.setUp()
    sut = MonthlyStatementsReportModule(serviceLocator: serviceLocator, statementReport: statementReport)
  }

  func testInitializeCompleteSucceed() {
    // Given
    var returnedResult: Result<UIViewController, NSError>?

    // When
    sut.initialize { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testInitializeSetUpPresenter() {
    // Given
    let presenter = serviceLocator.presenterLocatorFake.monthlyStatementsReportPresenter()

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.analyticsManager)
  }

  func testSutCreatedWithoutUrlInReportCallbackFailure() {
    // Given
    sut = MonthlyStatementsReportModule(serviceLocator: serviceLocator,
                                        statementReport: ModelDataProvider.provider.monthlyStatementReportWithoutUrl)

    // When
    sut.initialize { result in
      // Then
      XCTAssertTrue(result.isFailure)
      XCTAssertTrue(result.error is ServiceError)
    }
  }
}
