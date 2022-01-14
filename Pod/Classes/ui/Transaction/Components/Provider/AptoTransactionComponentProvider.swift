import AptoSDK

internal struct AptoTransactionComponentProvider: TransactionComponentProvider {
    private let serviceLocator: ServiceLocatorProtocol

    init(serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared) {
        self.serviceLocator = serviceLocator
    }

    // MARK: - Transaction List

    func makeTransactionList(with options: TransactionListOptions) -> TransactionListView {
        let config = TransactionListModuleConfig(startDate: nil, endDate: nil, categoryId: nil)
        let presenter = serviceLocator.presenterLocator.transactionListPresenter(
            config: options.config ?? config,
            transactionListEvents: options.events
        )
        let interactor = serviceLocator.interactorLocator.transactionListInteractor(card: options.card)
        let dataSource = TransactionListDataSource(uiConfig: options.uiConfig, presenter: presenter)

        presenter.interactor = interactor
        presenter.analyticsManager = serviceLocator.analyticsManager

        return TransactionListView(
            uiConfiguration: options.uiConfig,
            presenter: presenter,
            dataSource: dataSource
        )
    }

    // MARK: - Card

    func makeCardView() -> CreditCardView {
        makeCardView(with: .init())
    }

    func makeCardView(with options: CardViewOptions) -> CreditCardView {
        CreditCardView(uiConfiguration: options.uiConfig, cardStyle: options.cardStyle)
    }
}
