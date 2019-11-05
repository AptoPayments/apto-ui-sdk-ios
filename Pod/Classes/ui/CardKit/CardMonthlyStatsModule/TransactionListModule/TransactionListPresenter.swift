//
//  TransactionListPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/01/2019.
//

import AptoSDK
import Bond

class TransactionListPresenter: TransactionListPresenterProtocol {
  private let config: TransactionListModuleConfig
  private let rowsPerPage = 20
  private var lastTransactionId: String?

  let viewModel = TransactionListViewModel()
  weak var router: TransactionListModuleProtocol?
  var interactor: TransactionListInteractorProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: TransactionListModuleConfig) {
    self.config = config
  }

  func viewLoaded() {
    let title = config.categoryId?.name ?? "transactions.list.title".podLocalized()
    viewModel.title.send(title)
    fetchTransactions(showLoadingSpinner: true, clearCurrent: true) { _ in }
    analyticsManager?.track(event: Event.transactionList)
  }

  func closeTapped() {
    router?.close()
  }

  func reloadData() {
    fetchTransactions(showLoadingSpinner: false, clearCurrent: true) { _ in }
  }

  func loadMoreTransactions(completion: @escaping (_ noMoreTransactions: Bool) -> Void) {
    fetchTransactions(showLoadingSpinner: false, clearCurrent: false) { transactionsLoaded in
      completion(transactionsLoaded == 0)
    }
  }

  func transactionSelected(_ transaction: Transaction) {
    router?.showDetails(of: transaction)
  }

  // MARK: - Private methods
  private func fetchTransactions(showLoadingSpinner: Bool,
                                 clearCurrent: Bool,
                                 completion: @escaping (_ transactionsLoaded: Int) -> Void) {
    if showLoadingSpinner {
      router?.showLoadingSpinner()
    }
    if clearCurrent {
      lastTransactionId = nil
    }
    interactor?.fetchTransactions(filters: fetchTransactionFilters) { [weak self] result in
      if showLoadingSpinner {
        self?.router?.hideLoadingSpinner()
      }
      switch result {
      case .failure(let error):
        self?.router?.show(error: error)
        completion(0)
      case .success(let transactions):
        if clearCurrent {
          self?.viewModel.transactions.removeAllItemsAndSections()
        }
        self?.updateViewModel(with: transactions)
        completion(transactions.count)
      }
    }
  }

  private func updateViewModel(with transactions: [Transaction]) {
    if let lastTransaction = transactions.last {
      self.lastTransactionId = lastTransaction.transactionId
    }
    else {
      return
    }
    var sections = viewModel.transactions.sections.map { return $0.metadata }
    transactions.forEach { transaction in
      append(transaction: transaction, to: &sections)
    }
  }

  private var firstTransactionMonthPerYear = [Int: Int]()

  private func append(transaction: Transaction, to sections: inout [String]) {
    let transactionYear = transaction.createdAt.year
    let transactionMonth = transaction.createdAt.month
    if firstTransactionMonthPerYear[transactionYear] == nil {
      firstTransactionMonthPerYear[transactionYear] = transactionMonth
    }
    let isFirstMonthOfTheYearWithTransaction = firstTransactionMonthPerYear[transactionYear] == transactionMonth
    let sectionName = section(for: transaction, includeYearNumber: isFirstMonthOfTheYearWithTransaction)
    if let indexOfSection = sections.firstIndex(of: sectionName) {
      viewModel.transactions.appendItem(transaction, toSection: indexOfSection)
    }
    else {
      sections.append(sectionName)
      let section = Observable2DArraySection<String, Transaction>(metadata: sectionName, items: [transaction])
      viewModel.transactions.appendSection(section)
    }
  }

  private func section(for transaction: Transaction, includeYearNumber: Bool) -> String {
    let formatter = includeYearNumber ? yearDateFormatter : dateFormatter
    return formatter.string(from: transaction.createdAt)
  }

  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter
  }()

  private lazy var yearDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM, yyyy"
    return formatter
  }()

  private var fetchTransactionFilters: TransactionListFilters {
    return TransactionListFilters(rows: rowsPerPage,
                                  lastTransactionId: lastTransactionId,
                                  startDate: config.startDate,
                                  endDate: config.endDate,
                                  mccCode: config.categoryId?.rawValue)
  }
}
