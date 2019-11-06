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
    router?.showStatementReport(month: month)
  }

  // MARK: Private methods
  private func loadStatementsPeriod() {
    viewModel.dataLoaded.send(false)
    router?.showLoadingView()
    interactor?.fetchStatementsPeriod { [weak self] result in
      self?.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self?.viewModel.error.send(error)
      case .success(let statementsPeriod):
        self?.updatePeriod(statementsPeriod)
        self?.viewModel.dataLoaded.send(true)
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
        let section = Array2D<String, Month>(sectionsWithItems: [("\(currentYear)", [])])[sectionAt: 0]
        viewModel.months.appendSection(section)
      }
      viewModel.months.appendItem(month, toSectionAt: viewModel.months.tree.numberOfSections - 1)
    }
  }
}
