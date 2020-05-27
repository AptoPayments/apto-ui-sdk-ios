import AptoSDK
import Bond
import ReactiveKit

public class TransactionListView: UIView {
  
  private let disposeBag = DisposeBag()
  private let transactionsList = UITableView(frame: .zero, style: .grouped)
  private let presenter: TransactionListPresenterProtocol
  private let uiConfiguration: UIConfig
  private let dataSource: TransactionListDataSource
  
  public var onStateChanged: ((TransactionListState) -> Void)?
  
  init(uiConfiguration: UIConfig,
       presenter: TransactionListPresenterProtocol,
       dataSource: TransactionListDataSource)
  {
    self.presenter = presenter
    self.uiConfiguration = uiConfiguration
    self.dataSource = dataSource
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  public func loadTransactions() {
    onStateChanged?(.loading)
    presenter.viewLoaded()
  }
  
  private func setup() {
    setUpTransactionList()
    setUpViewModelSubscriptions()
  }
  
  private func setUpTransactionList() {
    addSubview(transactionsList)
    transactionsList.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    transactionsList.backgroundColor = .clear
    transactionsList.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 12))
    transactionsList.separatorStyle = .none
    transactionsList.estimatedRowHeight = 72
    transactionsList.rowHeight = UITableView.automaticDimension
    transactionsList.dataSource = dataSource
    transactionsList.delegate = dataSource
    transactionsList.sectionFooterHeight = 0
  }
}

// MARK: - View model subscriptions

private extension TransactionListView {
  private func setUpViewModelSubscriptions() {
    presenter.viewModel.transactions.observeNext { [weak self] event in
      self?.transactionsList.reloadData()
      self?.transactionsList.switchRefreshHeader(to: .normal(.success, 0.5))
      self?.transactionsList.switchRefreshFooter(to: .normal)
      self?.onStateChanged?(.loaded)
    }.dispose(in: disposeBag)
  }
}
