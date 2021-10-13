//
//  TransactionListViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/01/2019.
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit
import PullToRefreshKit
import SnapKit

class TransactionListViewController: AptoViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: TransactionListPresenterProtocol
  private let transactionsList = UITableView(frame: .zero, style: .grouped)
  private let footer = DefaultRefreshFooter.footer()

  init(uiConfiguration: UIConfig, presenter: TransactionListPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUpNavigationBar()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

extension TransactionListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.viewModel.transactions.tree.numberOfSections
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.viewModel.transactions.tree.numberOfItems(inSection: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let transaction = presenter.viewModel.transactions[itemAt: indexPath]
    let controller = transactionsListCellController(for: transaction)
    let cell = controller.cell(tableView)
    return cell
  }

  private func transactionsListCellController(for transaction: Transaction) -> CellController {
     return TransactionListCellControllerTheme2(transaction: transaction, uiConfiguration: uiConfiguration)
  }
}

extension TransactionListViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let transaction = presenter.viewModel.transactions[itemAt: indexPath]
    presenter.transactionSelected(transaction)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let title = presenter.viewModel.transactions.tree.sections[section].metadata
    return sectionHeaderView(with: title)
  }

  private func sectionHeaderView(with title: String) -> UIView {
    let containerView = UIView()
    containerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    let contentView = SectionHeaderViewTheme2(text: title, uiConfig: uiConfiguration)
    containerView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
    }
    return containerView
  }
}

// MARK: - View model subscriptions
private extension TransactionListViewController {
  func setUpViewModelSubscriptions() {
    presenter.viewModel.title.observeNext { [weak self] title in
      self?.title = title
    }.dispose(in: disposeBag)
    presenter.viewModel.transactions.observeNext { [weak self] event in
      self?.transactionsList.reloadData()
      self?.transactionsList.switchRefreshHeader(to: .normal(.success, 0.5))
      self?.transactionsList.switchRefreshFooter(to: .normal)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension TransactionListViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpNavigationBar()
    setUpTransactionList()
    createRefreshHeader()
    createRefreshFooter()
  }

  func setUpNavigationBar() {
    UIApplication.shared.keyWindow?.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    navigationController?.setNavigationBarHidden(false, animated: false)
    guard let navigationBar = navigationController?.navigationBar else { return }
    navigationBar.hideShadow()
    navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
    navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    navigationBar.layer.shadowOpacity = 1
    navigationBar.layer.shadowRadius = 8
    navigationBar.setUp(
      barTintColor: uiConfiguration.uiNavigationSecondaryColor,
      tintColor: uiConfiguration.iconTertiaryColor
    )
    navigationItem.leftBarButtonItem?.tintColor = uiConfiguration.iconTertiaryColor
    setNeedsStatusBarAppearanceUpdate()
  }

  func setUpTransactionList() {
    view.addSubview(transactionsList)
    transactionsList.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    transactionsList.backgroundColor = .clear
    transactionsList.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 12))
    transactionsList.separatorStyle = .none
    transactionsList.estimatedRowHeight = 72
    transactionsList.rowHeight = UITableView.automaticDimension
    transactionsList.dataSource = self
    transactionsList.delegate = self
    transactionsList.sectionFooterHeight = 0
  }

  func createRefreshHeader() {
    let header = DefaultRefreshHeader.header()
    header.imageRenderingWithTintColor = true
    header.tintColor = uiConfiguration.uiNavigationSecondaryColor
    header.textLabel.font = uiConfiguration.fontProvider.timestampFont
    transactionsList.configRefreshHeader(with: header, container: self) { [weak self] in
      self?.presenter.reloadData()
    }
  }

  func createRefreshFooter() {
    footer.tintColor = uiConfiguration.uiNavigationSecondaryColor
    footer.textLabel.font = uiConfiguration.fontProvider.timestampFont
    footer.textLabel.numberOfLines = 0
    footer.setText("manage.shift.card.refresh.title".podLocalized(), mode: .scrollAndTapToRefresh)
    footer.setText("manage.shift.card.refresh.loading".podLocalized(), mode: .refreshing)
    transactionsList.configRefreshFooter(with: footer, container: self) { [weak self] in
      self?.presenter.loadMoreTransactions { noMoreTransactions in
        if noMoreTransactions {
          self?.transactionsList.switchRefreshFooter(to: .noMoreData)
        }
      }
    }
  }
}
