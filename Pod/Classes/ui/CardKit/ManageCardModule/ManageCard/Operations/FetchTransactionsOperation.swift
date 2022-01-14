//
//  FetchTransactionsOperation.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/03/2019.
//

import AptoSDK

class FetchTransactionsOperation {
    private let transactionsProvider: TransactionsProvider
    private let filters: TransactionListFilters
    private let forceRefresh: Bool
    private let callback: Result<[Transaction], NSError>.Callback

    private(set) var isExecuting = false
    private(set) var isFinished = false
    private(set) var isCancelled = false {
        didSet {
            isExecuting = false
        }
    }

    init(transactionsProvider: TransactionsProvider, filters: TransactionListFilters, forceRefresh: Bool,
         callback: @escaping Result<[Transaction], NSError>.Callback)
    {
        self.transactionsProvider = transactionsProvider
        self.filters = filters
        self.forceRefresh = forceRefresh
        self.callback = callback
    }

    func start() {
        if isCancelled { return }
        isExecuting = true
        main()
    }

    func cancel() {
        isCancelled = true
    }

    private func main() {
        guard !isCancelled else { return }
        transactionsProvider.provideTransactions(filters: filters, forceRefresh: forceRefresh) { [weak self] result in
            guard let self = self, !self.isCancelled else { return }
            self.isExecuting = false
            self.isFinished = true
            self.callback(result)
        }
    }
}
