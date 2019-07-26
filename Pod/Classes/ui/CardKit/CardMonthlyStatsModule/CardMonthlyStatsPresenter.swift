//
//  CardMonthlyStatsPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/01/2019.
//

import Foundation
import AptoSDK

class CardMonthlyStatsPresenter: CardMonthlyStatsPresenterProtocol {
  private static let dateFormatter = DateFormatter.customDateFormatter(dateFormat: "MMyyyy")
  weak var router: CardMonthlyStatsModuleProtocol?
  var interactor: CardMonthlyStatsInteractorProtocol?
  let viewModel = CardMonthlyStatsViewModel()
  var analyticsManager: AnalyticsServiceProtocol?
  private var spendingByMonth = [String: MonthlySpending]()

  func viewLoaded() {
    loadSpending(for: Date())
    analyticsManager?.track(event: Event.monthlySpending)
  }

  func closeTapped() {
    router?.close()
  }

  func dateSelected(_ date: Date) {
    loadSpending(for: date)
  }

  func categorySpendingSelected(_ categorySpending: CategorySpending, date: Date) {
    guard let startDate = date.startOfMonth, let endDate = date.endOfMonth else { return }
    router?.showTransactions(for: categorySpending, startDate: startDate, endDate: endDate)
  }

  // MARK: - Private methods
  private func loadSpending(for date: Date) {
    if let spending = cachedSpending(for: date) {
      updateViewModelWith(spending: spending)
      return
    }
    router?.showLoadingView()
    interactor?.fetchMonthlySpending(date: date) { [weak self] result in
      self?.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self?.router?.show(error: error)
      case .success(let monthlySpending):
        self?.cache(spending: monthlySpending)
        self?.updateViewModelWith(spending: monthlySpending)
      }
    }
  }

  private func updateViewModelWith(spending: MonthlySpending) {
    viewModel.dataLoaded.send(true)
    viewModel.spentList.send(spending.spending.sorted(by: { $0.categoryId.name < $1.categoryId.name }))
    viewModel.previousSpendingExists.send(spending.previousSpendingExists)
    viewModel.nextSpendingExists.send(spending.nextSpendingExists)
  }

  private func cache(spending: MonthlySpending) {
    guard let date = spending.date else { return }
    let month = CardMonthlyStatsPresenter.dateFormatter.string(from: date)
    spendingByMonth[month] = spending
  }

  private func cachedSpending(for date: Date) -> MonthlySpending? {
    let month = CardMonthlyStatsPresenter.dateFormatter.string(from: date)
    return spendingByMonth[month]
  }
}
