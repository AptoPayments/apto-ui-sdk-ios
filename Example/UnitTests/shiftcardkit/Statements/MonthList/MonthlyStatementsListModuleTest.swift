//
//  MonthlyStatementsListModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 23/09/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class MonthlyStatementsListModuleTest: XCTestCase {
  private var sut: MonthlyStatementsListModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()
    sut = MonthlyStatementsListModule(serviceLocator: serviceLocator)
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
    let presenter = serviceLocator.presenterLocatorFake.monthlyStatementsListPresenter()

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.analyticsManager)
  }

  func testShowStatementReportShowMonthlyStatementsReportModule() {
    // Given
    let report = dataProvider.monthlyStatementReport
    let moduleLocator = serviceLocator.moduleLocatorFake
    let monthlyStatementsReportModule = moduleLocator.monthlyStatementsReportModuleSpy

    // When
    sut.showStatementReport(report)

    // Then
    XCTAssertTrue(monthlyStatementsReportModule.initializeCalled)
    XCTAssertNotNil(monthlyStatementsReportModule.onClose)
  }
}
