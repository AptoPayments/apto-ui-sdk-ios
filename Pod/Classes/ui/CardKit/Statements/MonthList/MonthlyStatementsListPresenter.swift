//
// MonthlyStatementsListPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/09/2019.
//

import Foundation
import AptoSDK
import Bond

class MonthlyStatementsListPresenter: MonthlyStatementsListPresenterProtocol {
  var router: MonthlyStatementsListModuleProtocol?
  var interactor: MonthlyStatementsListInteractorProtocol?
  var viewModel = MonthlyStatementsListViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  func viewLoaded() {
    analyticsManager?.track(event: .monthlyStatementsListStart)
    loadStatementsPeriod()
  }

  func closeTapped() {
    router?.close()
  }

  func monthSelected(_ month: Month) {
    router?.showLoadingView()
    interactor?.fetchStatement(month: month.month, year: month.year) { [weak self] result in
      self?.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self?.viewModel.error.send(error)
      case .success(let report):
        self?.processReport(report)
      }
    }
  }

  // MARK: Private methods
  private func loadStatementsPeriod() {
    router?.showLoadingView()
    interactor?.fetchStatementsPeriod { [weak self] result in
      self?.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self?.viewModel.error.send(error)
      case .success(let statementsPeriod):
        self?.updatePeriod(statementsPeriod)
      }
    }
  }

  private func updatePeriod(_ statementsPeriod: MonthlyStatementsPeriod) {
    viewModel.months.removeAllItems()
    let months = Array(statementsPeriod.availableMonths().reversed())
    guard !months.isEmpty else { return }
    var currentYear = -1
    months.forEach { month in
      if month.year != currentYear {
        currentYear = month.year
        viewModel.months.appendSection(Observable2DArraySection<String, Month>(metadata: "\(currentYear)", items: []))
      }
      viewModel.months.appendItem(month, toSection: viewModel.months.numberOfSections - 1)
    }
  }

  private func processReport(_ report: MonthlyStatementReport) {
    guard report.downloadUrl != nil else {
      viewModel.error.send(FetchStatementReportError())
      return
    }
    router?.showStatementReport(report)
  }
}