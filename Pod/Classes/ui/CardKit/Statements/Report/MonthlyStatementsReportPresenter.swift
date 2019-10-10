//
// MonthlyStatementsReportPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 25/09/2019.
//

import Foundation
import AptoSDK

class MonthlyStatementsReportPresenter: MonthlyStatementsReportPresenterProtocol {
  var router: MonthlyStatementsReportModuleProtocol?
  var interactor: MonthlyStatementsReportInteractorProtocol?
  let viewModel = MonthlyStatementsReportViewModel()
  var analyticsManager: AnalyticsServiceProtocol?
  private static let dateFormatter = DateFormatter.customLocalizedDateFormatter(dateFormat: "MMMM")

  func viewLoaded() {
    analyticsManager?.track(event: .monthlyStatementsReportStart)
    loadReportDate()
    downloadReport()
  }

  func closeTapped() {
    router?.close()
  }

  private func loadReportDate() {
    if let reportDate = interactor?.reportDate() {
      if let date = Calendar.current.date(from: DateComponents(month: reportDate.month)) {
        viewModel.month.send(MonthlyStatementsReportPresenter.dateFormatter.string(from: date))
      }
      viewModel.year.send(String(reportDate.year))
    }
  }

  private func downloadReport() {
    router?.showLoadingView()
    interactor?.downloadReport { [weak self] result in
      self?.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self?.viewModel.error.send(error)
      case .success(let url):
        self?.viewModel.url.send(url)
      }
    }
  }
}
