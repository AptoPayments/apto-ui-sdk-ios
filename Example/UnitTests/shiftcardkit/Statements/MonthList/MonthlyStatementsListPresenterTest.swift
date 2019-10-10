//
//  MonthlyStatementsListPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 23/09/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK
import Bond

class MonthlyStatementsListPresenterTest: XCTestCase {
  private var sut: MonthlyStatementsListPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = MonthlyStatementsListModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = MonthlyStatementsListInteractorFake()
  private let analyticsManager = AnalyticsManagerSpy()
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()
    sut = MonthlyStatementsListPresenter()
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedTrackAnalyticsEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.monthlyStatementsListStart, analyticsManager.lastEvent)
  }

  func testViewLoadedLoadPeriod() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.showLoadingViewCalled)
    XCTAssertTrue(interactor.fetchStatementsPeriodCalled)
  }

  func testLoadPeriodSucceedUpdateViewModelMonths() {
    // Given
    let period = MonthlyStatementsPeriod(start: Month(month: 12, year: 2018), end: Month(month: 1, year: 2019))
    interactor.nextFetchStatementsPeriodResult = .success(period)

    // When
    sut.viewLoaded()

    // Then
    let months = sut.viewModel.months
    XCTAssertEqual(2, months.numberOfSections)
    XCTAssertEqual(1, months.numberOfItems(inSection: 0))
    XCTAssertEqual(1, months.numberOfItems(inSection: 1))
    XCTAssertEqual("2019", months.sections[0].metadata)
    XCTAssertEqual("2018", months.sections[1].metadata)
    XCTAssertEqual(period.end, months[IndexPath(row: 0, section: 0)])
    XCTAssertEqual(period.start, months[IndexPath(row: 0, section: 1)])
  }

  func testLoadPeriodSucceedWithEmptyPeriodUpdateViewModelMonths() {
    // Given
    let period = MonthlyStatementsPeriod(start: Month(month: 2, year: 2019), end: Month(month: 1, year: 2019))
    interactor.nextFetchStatementsPeriodResult = .success(period)

    // When
    sut.viewLoaded()

    // Then
    let months = sut.viewModel.months
    XCTAssertEqual(0, months.numberOfSections)
  }

  func testLoadPeriodFailsUpdateViewModelError() {
    // Given
    let error = BackendError(code: .other)
    interactor.nextFetchStatementsPeriodResult = .failure(error)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(error, sut.viewModel.error.value)
  }

  func testCloseTappedCallClose() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }

  func testMonthSelectedCallInteractor() {
    // Given
    let month = dataProvider.month

    // When
    sut.monthSelected(month)

    // Then
    XCTAssertTrue(router.showLoadingViewCalled)
    XCTAssertTrue(interactor.fetchStatementCalled)
  }

  func testFetchStatementFailsUpdateError() {
    // Given
    let error = BackendError(code: .other)
    interactor.nextFetchStatementResult = .failure(error)
    let month = dataProvider.month

    // When
    sut.monthSelected(month)

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
    XCTAssertEqual(error, sut.viewModel.error.value)
  }

  func testFetchStatementSucceedWithoutUrlUpdateError() {
    // Given
    interactor.nextFetchStatementResult = .success(dataProvider.monthlyStatementReportWithoutUrl)
    let month = dataProvider.month

    // When
    sut.monthSelected(month)

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
    XCTAssertTrue(sut.viewModel.error.value is FetchStatementReportError)
  }

  func testFetchStatementSucceedCallRouterToShowReport() {
    // Given
    interactor.nextFetchStatementResult = .success(dataProvider.monthlyStatementReport)
    let month = dataProvider.month

    // When
    sut.monthSelected(month)

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
    XCTAssertTrue(router.showStatementReportCalled)
  }
}
