import AptoSDK

final class TransactionListDataSource: NSObject {
  
  private let presenter: TransactionListPresenterProtocol
  private let uiConfig: UIConfig
  
  init(uiConfig: UIConfig,
       presenter: TransactionListPresenterProtocol)
  {
    self.uiConfig = uiConfig
    self.presenter = presenter
  }
}

// MARK: - UITableViewDataSource

extension TransactionListDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    presenter.viewModel.transactions.tree.numberOfSections
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    presenter.viewModel.transactions.tree.numberOfItems(inSection: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let transaction = presenter.viewModel.transactions[itemAt: indexPath]
    let controller = transactionsListCellController(for: transaction)
    let cell = controller.cell(tableView)
    return cell
  }
  
  func transactionsListCellController(for transaction: Transaction) -> CellController {
    TransactionListCellControllerTheme2(transaction: transaction, uiConfiguration: uiConfig)
  }
}

// MARK: - UITableViewDelegate

extension TransactionListDataSource: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let transaction = presenter.viewModel.transactions[itemAt: indexPath]
    presenter.transactionSelected(transaction)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 36 }
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let title = presenter.viewModel.transactions.tree.sections[section].metadata
    return sectionHeaderView(with: title)
  }
  
  private func sectionHeaderView(with title: String) -> UIView {
    let containerView = UIView()
    containerView.backgroundColor = uiConfig.uiBackgroundSecondaryColor
    let contentView = SectionHeaderViewTheme2(text: title, uiConfig: uiConfig)
    containerView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
    }
    return containerView
  }
}
