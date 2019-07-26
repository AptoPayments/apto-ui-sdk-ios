//
//  ManageShiftCardPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 24/10/2017.
//
//

import Foundation
import AptoSDK
import Bond

class ManageShiftCardPresenter: ManageShiftCardPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  private var fetchTransactionOperationQueue: FetchTransactionOperationQueue!
  var view: ManageShiftCardViewProtocol!
  var interactor: ManageShiftCardInteractorProtocol! {
    didSet {
      fetchTransactionOperationQueue = FetchTransactionOperationQueue(transactionsProvider: interactor)
    }
  }
  weak var router: ManageShiftCardRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel: ManageShiftCardViewModel
  var analyticsManager: AnalyticsServiceProtocol?
  private let rowsPerPage = 20
  private var lastTransactionId: String?
  private let config: ManageShiftCardPresenterConfig
  private var cardInfoRetrieved = false
  private var transactionsInfoRetrieved = false
  private var remoteInfoRetrieved: Bool {
    return cardInfoRetrieved && transactionsInfoRetrieved
  }
  private var cardInfoDataTimeout: Date? = nil

  init(config: ManageShiftCardPresenterConfig) {
    self.config = config
    self.viewModel = ManageShiftCardViewModel()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(backgroundRefresh),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func viewLoaded() {
    interactor.provideFundingSource(forceRefresh: false) { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
      case .success(let card):
        if let wself = self {
          wself.updateViewModelWith(card: card)
          wself.refreshTransactions(forceRefresh: false) { [weak self] _ in
            self?.backgroundRefresh()
          }
        }
      }
    }
    analyticsManager?.track(event: Event.manageCard)
  }

  func closeTapped() {
    router.closeFromManageShiftCardViewer()
  }

  func nextTapped() {
    router.accountSettingsTappedInManageShiftCardViewer()
  }

  func cardTapped() {
    // Disable card settings if the card is pending activation
    guard viewModel.state.value != .created else { return }
    if viewModel.fundingSource.value?.state == .invalid {
      router.balanceTappedInManageShiftCardViewer()
    }
    else {
      router.cardSettingsTappedInManageShiftCardViewer()
    }
  }

  func cardSettingsTapped() {
    // Disable card settings if the card is pending activation
    guard viewModel.state.value != .created else { return }
    router.cardSettingsTappedInManageShiftCardViewer()
  }

  func balanceTapped() {
    router.balanceTappedInManageShiftCardViewer()
  }

  func transactionSelected(indexPath: IndexPath) {
    router.showTransactionDetails(transaction: viewModel.transactions.item(at: indexPath))
  }

  func activateCardTapped() {
    view.showLoadingSpinner()
    interactor.activateCard { [unowned self] result in
      self.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success:
        self.viewModel.state.send(.active)
      }
    }
  }

  func showCardStatsTapped() {
    router.showCardStatsTappedInManageCardViewer()
  }

  func refreshCard() {
    view.showLoadingSpinner()
    refreshCard { [unowned self] in
      self.view.hideLoadingSpinner()
    }
  }

  func refreshFundingSource() {
    interactor.provideFundingSource(forceRefresh: false) {  [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
      case .success(let card):
        guard let self = self else {
          return
        }
        self.updateViewModelWith(card: card)
      }
    }
  }

  func showCardInfo(completion: @escaping () -> Void) {
    view.showLoadingSpinner()
    interactor.loadCardInfo { [weak self] result in
      self?.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
      case .success(let cardDetails):
        if let wself = self {
          wself.updateViewModelWith(cardDetails: cardDetails)
          wself.viewModel.cardInfoVisible.send(true)
          wself.cardInfoDataTimeout = Date().add(2, units: Calendar.Component.minute)
        }
      }
      completion()
    }
  }

  func hideCardInfo() {
    viewModel.cardInfoVisible.send(false)
  }

  func reloadTapped(showSpinner: Bool) {
    refreshInfo(showSpinner: showSpinner)
    interactor.loadFundingSources { _ in }
  }

  func moreTransactionsTapped(completion: @escaping (_ noMoreTransactions: Bool) -> Void) {
    guard remoteInfoRetrieved else { return completion(true) }
    fetchTransactionOperationQueue.loadMoreTransactions(lastTransactionId: lastTransactionId,
                                                        rows: rowsPerPage) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success(let transactions):
        self.process(newTransactions: transactions)
        completion(transactions.count == 0)
      }
    }
  }

  func activatePhysicalCardTapped() {
    view.requestPhysicalActivationCode(completion: activatePhysicalCard)
    analyticsManager?.track(event: Event.manageCardActivatePhysicalCardOverlay)
    analyticsManager?.track(event: Event.manageCardGetPINNue)
  }

  // MARK: - Private methods

  @objc private func backgroundRefresh() {
    hideCardInfoIfNecessary()
    refreshCard { [weak self] in
      self?.cardInfoRetrieved = true
    }
    backgroundRefreshTransactions { [weak self] in
      self?.transactionsInfoRetrieved = true
    }
    interactor.loadFundingSources { _ in }
  }

  private func hideCardInfoIfNecessary() {
    if let timeout = cardInfoDataTimeout, timeout.timeIntervalSinceNow <= 0 {
      hideCardInfo()
      cardInfoDataTimeout = nil
    }
  }

  fileprivate func refreshInfo(showSpinner: Bool = true, completion: (() -> Void)? = nil) {
    if showSpinner {
      view.showLoadingSpinner()
    }
    refreshCard { [unowned self] in
      self.refreshTransactions { [unowned self] _ in
        if showSpinner {
          self.view.hideLoadingSpinner()
        }
        completion?()
      }
    }
  }

  fileprivate func refreshCard(completion: @escaping () -> Void) {
    interactor.reloadCard { [weak self] result in
      switch result {
      case .failure(let error):
        self?.view.show(error: error)
        completion()
      case .success(let card):
        if let wself = self {
          wself.updateViewModelWith(card: card)
          completion()
        }
      }
    }
  }

  private func updateViewModelWith(card: Card) {
    router.update(card: card)
    viewModel.cardHolder.send(card.cardHolder)
    viewModel.lastFour.send(card.lastFourDigits)
    viewModel.cardNetwork.send(card.cardNetwork)
    viewModel.fundingSource.send(card.fundingSource)
    if card.orderedStatus == .ordered && card.orderedStatus != viewModel.orderedStatus.value {
      viewModel.showPhysicalCardActivationMessage.send(true)
    }
    else {
      viewModel.showPhysicalCardActivationMessage.send(false)
    }
    viewModel.orderedStatus.send(card.orderedStatus)
    viewModel.spendableToday.send(card.spendableToday)
    viewModel.nativeSpendableToday.send(card.nativeSpendableToday)
    viewModel.cardStyle.send(card.cardStyle)
    viewModel.state.send(card.state)
    if let showActivateCardButton = config.showActivateCardButton {
      viewModel.isActivateCardFeatureEnabled.send(showActivateCardButton)
    }
    else {
      viewModel.isActivateCardFeatureEnabled.send(false)
    }
    if viewModel.cardLoaded.value == false {
      viewModel.cardLoaded.send(true)
    }
    if let showStatsButton = config.showStatsButton {
      viewModel.isStatsFeatureEnabled.send(showStatsButton)
    }
    else {
      viewModel.isStatsFeatureEnabled.send(false)
    }
  }

  private func updateViewModelWith(cardDetails: CardDetails) {
    viewModel.pan.send(cardDetails.pan)
    viewModel.cvv.send(cardDetails.cvv)
    let expirationComponents = cardDetails.expiration.split(separator: "-")
    if var year = UInt(expirationComponents[0]), let month = UInt(expirationComponents[1]) {
      if year > 99 { year = year - 2000 }
      viewModel.expirationMonth.send(month)
      viewModel.expirationYear.send(year)
    }
  }

  fileprivate func refreshTransactions(forceRefresh: Bool = true,
                                       completion: @escaping (_ transactionsLoaded: Int) -> Void) {
    viewModel.transactionsLoaded.send(false)
    fetchTransactionOperationQueue.reloadTransactions(rows: rowsPerPage,
                                                      forceRefresh: forceRefresh) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success(let transactions):
        self.viewModel.transactions.removeAllItemsAndSections()
        self.viewModel.transactionsLoaded.send(true)
        self.process(newTransactions: transactions)
        completion(transactions.count)
      }
    }
  }

  private func process(newTransactions transactions: [Transaction]) {
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

  private func backgroundRefreshTransactions(completion: @escaping () -> Void) {
    fetchTransactionOperationQueue.backgroundRefresh(rows: rowsPerPage) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure:
        break // A background operation shouldn't show an error to the user
      case .success(let transactions):
        self.process(backgroundTransactions: transactions)
        completion()
      }
    }
  }

  private func process(backgroundTransactions transactions: [Transaction]) {
    guard !transactions.isEmpty else { return }
    guard !viewModel.transactions.isEmpty else {
      self.process(newTransactions: transactions)
      return
    }
    let currentTopTransaction = viewModel.transactions[IndexPath(row: 0, section: 0)]
    guard let index = transactions.firstIndex(where: { currentTopTransaction.transactionId == $0.transactionId }) else {
      viewModel.transactions.removeAllItemsAndSections()
      self.process(newTransactions: transactions)
      return
    }
    var sections = viewModel.transactions.sections.map { return $0.metadata }
    for idx in (0 ..< index).reversed() {
      append(transaction: transactions[idx], to: &sections, asTopItem: true)
    }
  }

  private var firstTransactionMonthPerYear = [Int: Int]()

  private func append(transaction: Transaction, to sections: inout [String], asTopItem: Bool = false) {
    let transactionYear = transaction.createdAt.year
    let transactionMonth = transaction.createdAt.month
    if firstTransactionMonthPerYear[transactionYear] == nil {
      firstTransactionMonthPerYear[transactionYear] = transactionMonth
    }
    let isFirstMonthOfTheYearWithTransaction = firstTransactionMonthPerYear[transactionYear] == transactionMonth
    let sectionName = section(for: transaction, includeYearNumber: isFirstMonthOfTheYearWithTransaction)
    if let indexOfSection = sections.firstIndex(of: sectionName) {
      if asTopItem {
        viewModel.transactions.insert(item: transaction, at: IndexPath(row: 0, section: indexOfSection))
      }
      else {
        viewModel.transactions.appendItem(transaction, toSection: indexOfSection)
      }
    }
    else {
      sections.append(sectionName)
      let section = Observable2DArraySection<String, Transaction>(metadata: sectionName, items: [transaction])
      if asTopItem {
        viewModel.transactions.insert(section: section, at: 0)
      }
      else {
        viewModel.transactions.appendSection(section)
      }
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

  private func activatePhysicalCard(_ code: String) {
    view.showLoadingSpinner()
    interactor.activatePhysicalCard(code: code) { [unowned self] result in
      self.view.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.view.show(error: error)
      case .success:
        self.router.physicalActivationSucceed()
      }
    }
  }
}
