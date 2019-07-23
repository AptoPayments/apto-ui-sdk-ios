//
// CardMonthlyStatsPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/01/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class CardMonthlyStatsPresenterTest: XCTestCase {
  var sut: CardMonthlyStatsPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = CardMonthlyStatsModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = CardMonthlyStatsInteractorFake()
  private let dataProvider = ModelDataProvider.provider
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()

  override func setUp() {
    super.setUp()

    sut = CardMonthlyStatsPresenter()
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedCallInteractor() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.fetchMonthlySpendingCalled)
    XCTAssertTrue(router.showLoadingViewCalled)
  }

  func testFetchMonthlySpendingFailsShowError() {
    // Given
    interactor.nextNextMonthlySpendingResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
    XCTAssertTrue(router.showErrorCalled)
  }

  func testFetchMonthlySpendingSucceedUpdateViewModel() {
    // Given
    interactor.nextNextMonthlySpendingResult = .success(dataProvider.monthlySpending(date: Date()))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
    XCTAssertFalse(sut.viewModel.spentList.value.isEmpty)
  }

  func testDateSelectedCallInteractor() {
    // When
    sut.dateSelected(Date())

    // Then
    XCTAssertTrue(interactor.fetchMonthlySpendingCalled)
    XCTAssertTrue(router.showLoadingViewCalled)
  }

  func testFetchMonthlySpendingForSelectedDateFailsShowError() {
    // Given
    interactor.nextNextMonthlySpendingResult = .failure(BackendError(code: .other))

    // When
    sut.dateSelected(Date())

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
    XCTAssertTrue(router.showErrorCalled)
  }

  func testFetchMonthlySpendingForSelectedDateSucceedUpdateViewModel() {
    // Given
    interactor.nextNextMonthlySpendingResult = .success(dataProvider.monthlySpending(date: Date()))

    // When
    sut.dateSelected(Date())

    // Then
    XCTAssertTrue(router.hideLoadingViewCalled)
    XCTAssertFalse(sut.viewModel.spentList.value.isEmpty)
  }

  func testSpendingListIsSortedAndUpdateViewModel() {
    //Given
    let plane = CategorySpending(categoryId: .plane, spending: Amount(value: 100, currency: "USD"), difference: 10)
    let food = dataProvider.categorySpending
    let monthlySpending = MonthlySpending(previousSpendingExists: true, nextSpendingExists: true,
                                          spending: [plane, food], date: Date())
    interactor.nextNextMonthlySpendingResult = .success(monthlySpending)

    //When
    sut.dateSelected(Date())

    //Then
    XCTAssertEqual(MCCIcon.food, sut.viewModel.spentList.value[0].categoryId)
    XCTAssertEqual(MCCIcon.plane, sut.viewModel.spentList.value[1].categoryId)
  }

  func testSameMonthSelectedTwiceOnlyCallInteractorOneTime() {
    // Given
    let components = DateComponents(year: 2019, month: 1, day: 8)
    let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
    interactor.nextNextMonthlySpendingResult = .success(dataProvider.monthlySpending(date: date))
    sut.dateSelected(date)

    // When
    sut.dateSelected(date.add(1, units: .day)!) // swiftlint:disable:this force_unwrapping

    // Then
    XCTAssertEqual(1, interactor.fetchMonthlySpendingCallCounter)
  }

  func testSpendingWithPreviousDataCanSelectPreviousMonthReturnTrue() {
    // Given
    let components = DateComponents(year: 2019, month: 1, day: 8)
    let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
    let spending = dataProvider.monthlySpending(date: date, previousSpendingExists: true)
    interactor.nextNextMonthlySpendingResult = .success(spending)
    sut.dateSelected(date)

    // When
    let canSelectPreviousMonth = sut.viewModel.previousSpendingExists.value

    // Then
    XCTAssertTrue(canSelectPreviousMonth)
  }

  func testSpendingWithoutPreviousDataCanSelectPreviousMonthReturnFalse() {
    // Given
    let components = DateComponents(year: 2019, month: 1, day: 8)
    let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
    let spending = dataProvider.monthlySpending(date: date, previousSpendingExists: false)
    interactor.nextNextMonthlySpendingResult = .success(spending)
    sut.dateSelected(date)

    // When
    let canSelectPreviousMonth = sut.viewModel.previousSpendingExists.value

    // Then
    XCTAssertFalse(canSelectPreviousMonth)
  }

  func testSpendingWithNextDataCanSelectNextMonthReturnTrue() {
    // Given
    let components = DateComponents(year: 2019, month: 1, day: 8)
    let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
    let spending = dataProvider.monthlySpending(date: date, nextSpendingExists: true)
    interactor.nextNextMonthlySpendingResult = .success(spending)
    sut.dateSelected(date)

    // When
    let canSelectPreviousMonth = sut.viewModel.nextSpendingExists.value

    // Then
    XCTAssertTrue(canSelectPreviousMonth)
  }

  func testSpendingWithoutNextDataCanSelectNextMonthReturnFalse() {
    // Given
    let components = DateComponents(year: 2019, month: 1, day: 8)
    let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
    let spending = dataProvider.monthlySpending(date: date, nextSpendingExists: false)
    interactor.nextNextMonthlySpendingResult = .success(spending)
    sut.dateSelected(date)

    // When
    let canSelectPreviousMonth = sut.viewModel.nextSpendingExists.value

    // Then
    XCTAssertFalse(canSelectPreviousMonth)
  }

  func testCloseTappedCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }

  func testCategorySpendingSelectedCallRouterWithAppropriateDates() {
    // Given
    var components = DateComponents(year: 2019, month: 1, day: 8)
    let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
    components = DateComponents(year: 2019, month: 1, day: 1)
    let expectedStartDate = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
    components = DateComponents(year: 2019, month: 1, day: 31)
    let expectedEndDate = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping

    // When
    sut.categorySpendingSelected(dataProvider.categorySpending, date: date)

    // Then
    XCTAssertTrue(router.showTransactionForCategoryCalled)
    XCTAssertEqual(expectedStartDate, router.lastCategorySpendingStartDate)
    XCTAssertEqual(expectedEndDate, router.lastCategorySpendingEndDate)
  }

  func testViewLoadedLogMonthlySpendingEvent() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.monthlySpending)
  }
}
