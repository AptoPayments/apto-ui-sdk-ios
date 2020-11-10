//
// FetchTransactionOperationQueue.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 21/03/2019.
//

import AptoSDK

class FetchTransactionOperationQueue {
  private let transactionsProvider: TransactionsProvider
  private var reloadOperation: FetchTransactionsOperation?
  private var loadMoreOperation: FetchTransactionsOperation?
  private var backgroundRefreshOperation: FetchTransactionsOperation?

  private var availableStates: [TransactionState] {
    return transactionsProvider.isShowDetailedCardActivityEnabled() ? [.complete, .declined] : [.complete]
  }

  init(transactionsProvider: TransactionsProvider) {
    self.transactionsProvider = transactionsProvider
  }

  func reloadTransactions(rows: Int = 20, forceRefresh: Bool = true,
                          callback: @escaping Result<[Transaction], NSError>.Callback) {
    guard !isReloadInProgress else { return }
    loadMoreOperation?.cancel()
    backgroundRefreshOperation?.cancel()
    let operation = FetchTransactionsOperation(transactionsProvider: transactionsProvider,
                                               filters: TransactionListFilters(rows: rows, states: availableStates),
                                               forceRefresh: forceRefresh,
                                               callback: callback)
    reloadOperation = operation
    operation.start()
  }

  func loadMoreTransactions(lastTransactionId: String? = nil, rows: Int = 20,
                            callback: @escaping Result<[Transaction], NSError>.Callback) {
    guard !isReloadInProgress, !isLoadMoreInProgress else { return }
    let filters = TransactionListFilters(rows: rows, lastTransactionId: lastTransactionId, states: availableStates)
    let operation = FetchTransactionsOperation(transactionsProvider: transactionsProvider,
                                               filters: filters,
                                               forceRefresh: true,
                                               callback: callback)
    loadMoreOperation = operation
    operation.start()
  }

  func backgroundRefresh(rows: Int = 20, callback: @escaping Result<[Transaction], NSError>.Callback) {
    guard !isReloadInProgress, !isBackgroundRefreshInProgress else { return }
    let operation = FetchTransactionsOperation(transactionsProvider: transactionsProvider,
                                               filters: TransactionListFilters(rows: rows, states: availableStates),
                                               forceRefresh: true,
                                               callback: callback)
    backgroundRefreshOperation = operation
    operation.start()
  }

  private var isReloadInProgress: Bool {
    guard let reloadOperation = self.reloadOperation else {
      return false
    }
    return reloadOperation.isExecuting
  }

  private var isLoadMoreInProgress: Bool {
    guard let loadMoreOperation = self.loadMoreOperation else {
      return false
    }
    return loadMoreOperation.isExecuting
  }

  private var isBackgroundRefreshInProgress: Bool {
    guard let backgroundRefreshOperation = self.backgroundRefreshOperation else {
      return false
    }
    return backgroundRefreshOperation.isExecuting
  }
}
