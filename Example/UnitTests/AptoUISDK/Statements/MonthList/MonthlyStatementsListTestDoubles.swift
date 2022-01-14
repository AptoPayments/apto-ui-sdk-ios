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
    private(set) var lastShowStatementReportMonth: Month?
    func showStatementReport(month: Month) {
        showStatementReportCalled = true
        lastShowStatementReportMonth = month
    }
}

class MonthlyStatementsListInteractorSpy: MonthlyStatementsListInteractorProtocol {
    private(set) var fetchStatementsPeriodCalled = false
    func fetchStatementsPeriod(callback _: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
        fetchStatementsPeriodCalled = true
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
