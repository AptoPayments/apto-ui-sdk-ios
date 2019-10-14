//
// CardMonthlyStatsContract.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/01/2019.
//

import AptoSDK
@testable import AptoUISDK

class CardMonthlyStatsModuleSpy: UIModuleSpy, CardMonthlyStatsModuleProtocol {
  private(set) var showTransactionForCategoryCalled = false
  private(set) var lastCategorySpending: CategorySpending?
  private(set) var lastCategorySpendingStartDate: Date?
  private(set) var lastCategorySpendingEndDate: Date?
  func showTransactions(for categorySpending: CategorySpending, startDate: Date, endDate: Date) {
    showTransactionForCategoryCalled = true
    lastCategorySpending = categorySpending
    lastCategorySpendingStartDate = startDate
    lastCategorySpendingEndDate = endDate
  }

  private(set) var showStatementReportCalled = false
  private(set) var lastShowStatementReportMonth: Month?
  func showStatementReport(month: Month) {
    showStatementReportCalled = true
    lastShowStatementReportMonth = month
  }
}

class CardMonthlyStatsInteractorSpy: CardMonthlyStatsInteractorProtocol {
  private(set) var fetchMonthlySpendingCalled = false
  private(set) var lastDateToFetchData: Date?
  private(set) var fetchMonthlySpendingCallCounter = 0
  func fetchMonthlySpending(date: Date, callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    fetchMonthlySpendingCalled = true
    lastDateToFetchData = date
    fetchMonthlySpendingCallCounter += 1
  }
}

class CardMonthlyStatsInteractorFake: CardMonthlyStatsInteractorSpy {
  var nextNextMonthlySpendingResult: Result<MonthlySpending, NSError>?
  override func fetchMonthlySpending(date: Date, callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    super.fetchMonthlySpending(date: date, callback: callback)

    if let result = nextNextMonthlySpendingResult {
      callback(result)
    }
  }
}

class CardMonthlyStatsPresenterSpy: CardMonthlyStatsPresenterProtocol {
  var router: CardMonthlyStatsModuleProtocol?
  var interactor: CardMonthlyStatsInteractorProtocol?
  let viewModel = CardMonthlyStatsViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var dateSelectedCalled = false
  private(set) var lastDateSelected: Date?
  func dateSelected(_ date: Date) {
    dateSelectedCalled = true
    lastDateSelected = date
  }

  private(set) var categorySpendingSelectedCalled = false
  private(set) var lastCategorySpendingSelected: CategorySpending?
  private(set) var lastCategorySpendingSelectedDate: Date?
  func categorySpendingSelected(_ categorySpending: CategorySpending, date: Date) {
    categorySpendingSelectedCalled = true
    lastCategorySpendingSelected = categorySpending
    lastCategorySpendingSelectedDate = date
  }

  private(set) var monthlyStatementsTappedCalled = false
  private(set) var lastMonthlyStatementsTappedDate: Date?
  func monthlyStatementsTapped(date: Date) {
    monthlyStatementsTappedCalled = true
    lastMonthlyStatementsTappedDate = date
  }
}
