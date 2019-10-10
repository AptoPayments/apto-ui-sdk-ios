//
//  MonthlyStatementsListTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 23/09/2019.
//

@testable import AptoSDK
@testable import AptoUISDK

class MonthlyStatementsListModuleSpy: UIModuleSpy, MonthlyStatementsListModuleProtocol {
  private(set) var showStatementReportCalled = false
  private(set) var lastShowStatementReport: MonthlyStatementReport?
  func showStatementReport(_ report: MonthlyStatementReport) {
    showStatementReportCalled = true
    lastShowStatementReport = report
  }
}

class MonthlyStatementsListInteractorSpy: MonthlyStatementsListInteractorProtocol {
  private(set) var fetchStatementsPeriodCalled = false
  func fetchStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
    fetchStatementsPeriodCalled = true
  }

  private(set) var fetchStatementCalled = false
  private(set) var lastFetchStatementMonth: Int?
  private(set) var lastFetchStatementYear: Int?
  func fetchStatement(month: Int, year: Int, callback: @escaping Result<MonthlyStatementReport, NSError>.Callback) {
    fetchStatementCalled = true
    lastFetchStatementMonth = month
    lastFetchStatementYear = year
  }
}

class MonthlyStatementsListInteractorFake: MonthlyStatementsListInteractorSpy {
  var nextFetchStatementsPeriodResult: Result<MonthlyStatementsPeriod, NSError>?
  override func fetchStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
    super.fetchStatementsPeriod(callback: callback)
    if let result = nextFetchStatementsPeriodResult {
      callback(result)
    }
  }

  var nextFetchStatementResult: Result<MonthlyStatementReport, NSError>?
  override func fetchStatement(month: Int, year: Int,
                               callback: @escaping Result<MonthlyStatementReport, NSError>.Callback) {
    super.fetchStatement(month: month, year: year, callback: callback)
    if let result = nextFetchStatementResult {
      callback(result)
    }
  }
}

class MonthlyStatementsListPresenterSpy: MonthlyStatementsListPresenterProtocol {
  let viewModel = MonthlyStatementsListViewModel()
  var interactor: MonthlyStatementsListInteractorProtocol?
  var router: MonthlyStatementsListModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var monthSelectedCalled = false
  private(set) var lastMonthSelectedMonth: Month?
  func monthSelected(_ month: Month) {
    monthSelectedCalled = true
    lastMonthSelectedMonth = month
  }
}
