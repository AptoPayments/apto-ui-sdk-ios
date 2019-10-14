//
//  CardMonthlyStatsViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/01/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class CardMonthlyStatsViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: CardMonthlyStatsPresenterProtocol
  private static let yearDateFormatter = DateFormatter.customDateFormatter(dateFormat: "yyyy")
  private let monthsView: CardMonthlyStatsMonthsView
  private let graphContainerView = UIView()
  private let graphView: PieChartView
  private let graphSummaryView: CardMonthlyStatsGraphSummaryView
  private let spentListTableView = UITableView(frame: .zero, style: .grouped)
  private let emptyCaseView = UIView()
  private let monthlyStatementsContainerView = UIView()
  private var spentList = [CategorySpending]()
  private var groupedSpentList = [GraphData]()
  private var selectedSlice: GraphData?
  private var totalSpent: Double = 0
  private var previousDate: Date?
  private var currentDate: Date = Date() {
    didSet {
      previousDate = oldValue
      setUpTitle()
      selectedSlice = nil
      monthsView.set(date: currentDate, animated: true)
      presenter.dateSelected(currentDate)
    }
  }

  init(uiConfiguration: UIConfig, presenter: CardMonthlyStatsPresenterProtocol) {
    self.presenter = presenter
    self.monthsView = CardMonthlyStatsMonthsView(uiConfig: uiConfiguration)
    self.graphView = PieChartView(frame: .zero)
    self.graphSummaryView = CardMonthlyStatsGraphSummaryView(uiConfig: uiConfiguration)
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

// MARK: - View model subscriptions
private extension CardMonthlyStatsViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    combineLatest(viewModel.dataLoaded, viewModel.spentList).observeNext { [weak self] dataLoaded, spentList in
      guard dataLoaded == true else { return }
      self?.buildGraphData(from: spentList)
      self?.updateUI()
    }.dispose(in: disposeBag)
    viewModel.previousSpendingExists.observeNext { [weak self] previousSpendingExists in
      self?.monthsView.showPreviousMonth = previousSpendingExists
    }.dispose(in: disposeBag)
    viewModel.nextSpendingExists.observeNext { [weak self] nextSpendingExists in
      self?.monthsView.showNextMonth = nextSpendingExists
    }.dispose(in: disposeBag)
    viewModel.monthlyStatementsAvailable.observeNext { [weak self] monthlyStatementsAvailable in
      self?.monthlyStatementsContainerView.isHidden = !monthlyStatementsAvailable
    }.dispose(in: disposeBag)
  }

  func updateUI() {
    let viewModel = presenter.viewModel
    graphView.build()
    showSummaryTotal()
    reloadSpentList(newSpentList: presenter.viewModel.spentList.value)
    // Only show the empty case if we are all set
    if viewModel.dataLoaded.value == true {
      let shouldShowEmptyCase = viewModel.spentList.value.isEmpty
      emptyCaseView.isHidden = !shouldShowEmptyCase
      if shouldShowEmptyCase {
        showEmptyCase()
      }
      else {
        emptyCaseView.removeFromSuperview()
      }
    }
  }

  var deleteAnimation: UITableView.RowAnimation {
    guard let previousDate = self.previousDate else { return .automatic }
    return previousDate.isLessThanDate(currentDate) ? .left : .right
  }

  var insertAnimation: UITableView.RowAnimation {
    guard let previousDate = self.previousDate else { return .automatic }
    return previousDate.isLessThanDate(currentDate) ? .right : .left
  }

  func reloadSpentList(newSpentList: [CategorySpending]) {
    spentListTableView.beginUpdates()
    let indexPaths: [IndexPath] = spentList.enumerated().map { (index, _) in
      return IndexPath(row: index, section: 0)
    }
    spentListTableView.deleteRows(at: indexPaths, with: deleteAnimation)
    spentList.removeAll()
    for spent in newSpentList {
      spentList.append(spent)
      spentListTableView.insertRows(at: [IndexPath(row: spentList.count - 1, section: 0)], with: insertAnimation)
    }
    spentListTableView.endUpdates()
  }

  func showEmptyCase() {
    emptyCaseView.removeFromSuperview()
    emptyCaseView.snp.removeConstraints()
    view.addSubview(emptyCaseView)
    emptyCaseView.snp.makeConstraints { make in
      let topMargin = spentListTopMargin + tableView(spentListTableView, heightForHeaderInSection: 0)
      make.top.equalTo(graphView.snp.bottom).offset(topMargin)
      make.left.right.bottom.equalToSuperview()
    }
    view.bringSubviewToFront(emptyCaseView)
  }

  func buildGraphData(from spentList: [CategorySpending]) {
    totalSpent = 0
    spentList.forEach { spending in
      totalSpent += (spending.spending.amount.value ?? 0)
    }
    let defaultCurrency = "stats.monthly_spending.graph.default_currency".podLocalized()
    var other = GraphData(categories: [],
                          amount: 0,
                          difference: nil,
                          currency: defaultCurrency)
    var graphList = [GraphData]()
    for spending in spentList {
      guard let amount = spending.spending.amount.value else {
        continue
      }
      // Values below 7% of the total will be grouped
      if amount / totalSpent > 0.07 {
        graphList.append(GraphData(categories: [spending.categoryId],
                                   amount: amount,
                                   difference: spending.difference,
                                   currency: spending.spending.currency.value ?? defaultCurrency))
      }
      else {
        other.categories.append(spending.categoryId)
        other.amount += amount
        if other.currency == defaultCurrency, let currency = spending.spending.currency.value {
          other.currency = currency
        }
      }
    }
    if !other.categories.isEmpty {
      graphList.insert(other, at: 0)
    }
    self.groupedSpentList = graphList
  }

  func showSummaryTotal() {
    let amount: Amount
    if let spending = presenter.viewModel.spentList.value.first {
      amount = Amount(value: totalSpent, currency: spending.spending.currency.value)
    }
    else {
      amount = Amount(value: 0, currency: "stats.monthly_spending.graph.default_currency".podLocalized())
    }
    graphSummaryView.set(title: "stats.monthly_spending.graph.title".podLocalized(), amount: amount, difference: nil)
  }

  func showSummaryForSlice(at index: Int) {
    let graphData = groupedSpentList[index]
    graphSummaryView.set(title: graphData.name,
                         amount: Amount(value: graphData.amount, currency: graphData.currency),
                         difference: graphData.difference)
  }
}

// MARK: - Months view delegate
extension CardMonthlyStatsViewController: CardMonthlyStatsMonthsViewDelegate {
  func leftLabelTapped(associatedDate: Date?) {
    guard presenter.viewModel.previousSpendingExists.value == true, let date = associatedDate else { return }
    currentDate = date
  }

  func centerLabelTapped(associatedDate: Date?) {
    // Do not reselect the current month
  }

  func rightLabelTapped(associatedDate: Date?) {
    guard presenter.viewModel.nextSpendingExists.value == true, let date = associatedDate else { return }
    currentDate = date
  }
}

extension CardMonthlyStatsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.viewModel.spentList.value.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let spending = presenter.viewModel.spentList.value[indexPath.row]
    let controller = CategorySpendingCellController(categorySpending: spending, uiConfig: uiConfiguration)
    let cell = controller.cell(tableView)
    if let selectedSlice = self.selectedSlice {
      controller.isHighlighted = selectedSlice.categories.contains(spending.categoryId)
    }
    else {
      controller.isHighlighted = false
    }
    return cell
  }
}

extension CardMonthlyStatsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let containerView = UIView()
    containerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    let contentView = SectionHeaderViewTheme2(text: "stats.monthly_spending.list.title".podLocalized(),
                                              uiConfig: uiConfiguration)
    containerView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
    }
    return containerView
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let categorySpending = spentList[indexPath.row]
    presenter.categorySpendingSelected(categorySpending, date: currentDate)
  }
}

extension CardMonthlyStatsViewController: PieChartViewDataSource {
  func separatorColor() -> UIColor {
    return uiConfiguration.iconPrimaryColor
  }

  func colorForSlice(at index: Int) -> UIColor {
    return uiConfiguration.uiTertiaryColor
  }

  func selectedColorForSlice(at index: Int) -> UIColor {
    return uiConfiguration.uiPrimaryColor
  }

  func valueForSlice(at index: Int) -> CGFloat {
    return CGFloat(groupedSpentList[index].amount)
  }

  func imageForSlice(at index: Int) -> UIImage? {
    if groupedSpentList[index].categories.count == 1 {
      return groupedSpentList[index].categories[0].image()
    }
    else {
      return nil
    }
  }

  func imageTintColorForSlice(at index: Int) -> UIColor {
    return uiConfiguration.iconSecondaryColor
  }

  func numberOfSlices() -> Int {
    return groupedSpentList.count
  }
}

extension CardMonthlyStatsViewController: PieChartViewDelegate {
  func didSelectSlice(at index: Int) {
    selectedSlice = groupedSpentList[index]
    showSummaryForSlice(at: index)
    spentListTableView.reloadData()
  }

  func didDeselectSlice(at index: Int) {
    selectedSlice = nil
    showSummaryTotal()
    spentListTableView.reloadData()
  }
}

// MARK: - Set up UI
private extension CardMonthlyStatsViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpTitle()
    setUpNavigationBar()
    setUpNavigationBarShadow()
    setUpMonthsView()
    setUpGraphContainerView()
    setUpGraphView()
    setUpMonthlyStatements()
    setUpSpentListTableView()
    setUpEmptyCaseView()
  }

  func setUpTitle() {
    let title = "stats.monthly_spending.title".podLocalized()
    self.title = title.replace(["<<YEAR>>": CardMonthlyStatsViewController.yearDateFormatter.string(from: currentDate)])
  }

  func setUpNavigationBar() {
    switch uiConfiguration.uiTheme {
    case .theme1:
      navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    case .theme2:
      navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationSecondaryColor,
                                                tintColor: uiConfiguration.iconTertiaryColor)
    }
    navigationItem.leftBarButtonItem?.tintColor = uiConfiguration.iconTertiaryColor
    setNeedsStatusBarAppearanceUpdate()
  }

  func setUpNavigationBarShadow() {
    guard let navigationBar = navigationController?.navigationBar else { return }
    navigationBar.layer.shadowOffset = CGSize(width: 0, height: -2)
    navigationBar.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
    navigationBar.layer.shadowOpacity = 1
    navigationBar.layer.shadowRadius = 8
  }

  func setUpMonthsView() {
    monthsView.set(date: Date(), animated: false)
    monthsView.delegate = self
    view.addSubview(monthsView)
    monthsView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(24)
      make.left.right.equalToSuperview().inset(36)
    }
  }

  private func setUpGraphContainerView() {
    view.addSubview(graphContainerView)
    graphContainerView.snp.makeConstraints { make in
      make.top.equalTo(monthsView.snp.bottom).offset(16)
      make.left.right.equalToSuperview()
    }
    let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(_:)))
    swipe.direction = .left
    graphContainerView.addGestureRecognizer(swipe)
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(_:)))
    rightSwipe.direction = .right
    graphContainerView.addGestureRecognizer(rightSwipe)
  }

  @objc private func swipeDetected(_ gesture: UISwipeGestureRecognizer) {
    if gesture.direction == .right {
      monthsView.leftLabelTapped()
    }
    else {
      monthsView.rightLabelTapped()
    }
  }

  func setUpGraphView() {
    graphContainerView.addSubview(graphView)
    graphView.dataSource = self
    graphView.delegate = self
    graphView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.width.height.equalTo(graphViewWidth)
      make.centerX.equalToSuperview()
    }
    graphView.addSubview(graphSummaryView)
    graphSummaryView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.right.equalToSuperview().inset(68)
    }
  }

  func setUpMonthlyStatements() {
    monthlyStatementsContainerView.backgroundColor = view.backgroundColor
    view.addSubview(monthlyStatementsContainerView)
    monthlyStatementsContainerView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(graphContainerView.snp.bottom)
      make.height.equalTo(spentListTopMargin)
    }
    let title = "stats.monthly_spending.statements_report.view".podLocalized()
    let button = ComponentCatalog.formTextLinkButtonWith(title: title, uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.monthlyStatementsTapped(date: self.currentDate)
    }
    monthlyStatementsContainerView.addSubview(button)
    button.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  func setUpSpentListTableView() {
    spentListTableView.backgroundColor = .clear
    view.addSubview(spentListTableView)
    spentListTableView.snp.makeConstraints { make in
      make.top.equalTo(monthlyStatementsContainerView.snp.bottom)
      make.left.right.bottom.equalToSuperview()
    }
    spentListTableView.separatorStyle = .none
    spentListTableView.estimatedRowHeight = 72
    spentListTableView.rowHeight = UITableView.automaticDimension
    spentListTableView.dataSource = self
    spentListTableView.delegate = self
    spentListTableView.sectionFooterHeight = 0
  }

  func setUpEmptyCaseView() {
    emptyCaseView.backgroundColor = .clear
    let label = ComponentCatalog.sectionTitleLabelWith(text: "stats.monthly_spending.list.empty_case".podLocalized(),
                                                       textAlignment: .center,
                                                       uiConfig: uiConfiguration)
    label.textColor = uiConfiguration.textTertiaryColor
    label.numberOfLines = 0
    emptyCaseView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.centerY.equalToSuperview().offset(-16)
    }
  }

  var graphViewWidth: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 230
    default:
      return 256
    }
  }

  var spentListTopMargin: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 24
    default:
      return 54
    }
  }
}

/// Helper struct to consolidate graph data
private struct GraphData {
  var categories: [MCCIcon] = []
  var amount: Double
  var difference: Double?
  var currency: String

  var name: String {
    if categories.count == 1 {
      return categories[0].name
    }
    else {
      return "stats.monthly_spending.graph.grouped.title".podLocalized()
    }
  }
}
