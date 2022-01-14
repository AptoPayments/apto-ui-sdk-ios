//
// TransactionListTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/01/2019.
//

import AptoSDK
@testable import AptoUISDK

class TransactionListModuleSpy: UIModuleSpy, TransactionListModuleProtocol {
    private(set) var showTransactionDetailsCalled = false
    private(set) var lastTransactionToShowDetails: Transaction?
    func showDetails(of transaction: Transaction) {
        showTransactionDetailsCalled = true
        lastTransactionToShowDetails = transaction
    }
}

class TransactionListInteractorSpy: TransactionListInteractorProtocol {
    private(set) var fetchTransactionsCalled = false
    private(set) var lastFetchTransactionsFilters: TransactionListFilters?
    func fetchTransactions(filters _: TransactionListFilters, callback _: @escaping Result<[Transaction], NSError>.Callback) {
        fetchTransactionsCalled = true
    }
}

class TransactionListInteractorFake: TransactionListInteractorSpy {
    var nextFetchTransactionsResult: Result<[Transaction], NSError>?
    override func fetchTransactions(filters: TransactionListFilters,
                                    callback: @escaping Result<[Transaction], NSError>.Callback)
    {
        super.fetchTransactions(filters: filters, callback: callback)

        if let result = nextFetchTransactionsResult {
            callback(result)
        }
    }
}

class TransactionListPresenterSpy: TransactionListPresenterProtocol {
    let viewModel = TransactionListViewModel()
    weak var router: TransactionListModuleProtocol?
    var interactor: TransactionListInteractorProtocol?
    var analyticsManager: AnalyticsServiceProtocol?

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }

    private(set) var reloadDataCalled = false
    func reloadData() {
        reloadDataCalled = true
    }

    private(set) var loadMoreTransactionsCalled = false
    func loadMoreTransactions(completion _: @escaping (_ noMoreTransactions: Bool) -> Void) {
        loadMoreTransactionsCalled = true
    }

    private(set) var transactionSelectedCalled = false
    private(set) var lastTransactionSelected: Transaction?
    func transactionSelected(_ transaction: Transaction) {
        transactionSelectedCalled = true
        lastTransactionSelected = transaction
    }
}
