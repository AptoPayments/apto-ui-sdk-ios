//
//  MonthlyStatementsListViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 23/09/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class MonthlyStatementsListViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: MonthlyStatementsListPresenterProtocol
  private let tableView = UITableView(frame: .zero, style: .grouped)
  private let emptyCaseView = UIView()
  static private let _dateFormatter = DateFormatter.customLocalizedDateFormatter(dateFormat: "MMMM")
  private lazy var dateFormatter = MonthlyStatementsListViewController._dateFormatter

  init(uiConfiguration: UIConfig, presenter: MonthlyStatementsListPresenterProtocol) {
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

  override func closeTapped() {
    presenter.closeTapped()
  }
}

extension MonthlyStatementsListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.viewModel.months.numberOfSections
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.viewModel.months.numberOfItems(inSection: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let months = presenter.viewModel.months
    let month = months[indexPath]
    let controller = MonthlyStatementListCellController(month: month, uiConfig: uiConfiguration)
    let cell = controller.cell(tableView)
    controller.shouldDrawBottomDivider = shouldDrawBottomDivider(indexPath: indexPath, months: months)
    return cell
  }

  private func shouldDrawBottomDivider(indexPath: IndexPath, months: MutableObservable2DArray<String, Month>) -> Bool {
    if indexPath.section == (months.numberOfSections - 1) {
      return true
    }
    return indexPath.row != (months.numberOfItems(inSection: indexPath.section) - 1)
  }
}

extension MonthlyStatementsListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let containerView = UIView()
    containerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    let contentView = SectionHeaderViewTheme2(text: String(presenter.viewModel.months.sections[section].metadata),
                                              uiConfig: uiConfiguration)
    containerView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
    }
    return containerView
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let month = presenter.viewModel.months[indexPath]
    presenter.monthSelected(month)
  }
}

private extension MonthlyStatementsListViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.error.ignoreNils().observeNext { [weak self] error in
      self?.show(error: error)
    }.dispose(in: disposeBag)
    viewModel.months.observeNext { [weak self] _ in
      self?.tableView.reloadData()
    }.dispose(in: disposeBag)
    combineLatest(viewModel.dataLoaded, viewModel.months).observeNext { [weak self] dataLoaded, months in
      guard dataLoaded else { return }
      self?.emptyCaseView.isHidden = !months.source.isEmpty
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension MonthlyStatementsListViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpTitle()
    setUpNavigationBar()
    setUpTableView()
    setUpEmptyCase()
  }

  func setUpTitle() {
    self.title = "monthly_statements.list.title".podLocalized()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationSecondaryColor,
                                              tintColor: uiConfiguration.textTopBarSecondaryColor)
    navigationItem.leftBarButtonItem?.tintColor = uiConfiguration.textTopBarSecondaryColor
    setNeedsStatusBarAppearanceUpdate()
  }

  func setUpTableView() {
    tableView.backgroundColor = view.backgroundColor
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.left.bottom.right.equalToSuperview()
    }
    tableView.separatorStyle = .none
    tableView.rowHeight = 74
    tableView.sectionFooterHeight = 0
    tableView.dataSource = self
    tableView.delegate = self
  }

  func setUpEmptyCase() {
    emptyCaseView.isHidden = true
    view.addSubview(emptyCaseView)
    emptyCaseView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    let message = "monthly_statements.list.empty_case.message".podLocalized()
    let label = ComponentCatalog.sectionTitleLabelWith(text: message,
                                                       textAlignment: .center,
                                                       uiConfig: uiConfiguration)
    label.textColor = uiConfiguration.textTertiaryColor
    label.numberOfLines = 0
    emptyCaseView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
    }
  }
}
