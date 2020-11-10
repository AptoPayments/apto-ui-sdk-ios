//
// ManageCardTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

import AptoSDK
@testable import AptoUISDK

class ManageCardModuleSpy: UIModuleSpy, ManageCardRouterProtocol {
  private(set) var updateCardCalled = false
  private(set) var lastCardUpdated: Card?
  func update(card newCard: Card) {
    updateCardCalled = true
    lastCardUpdated = newCard
  }

  private(set) var backFromManageCardViewerCalled = false
  func backFromManageCardViewer() {
    backFromManageCardViewerCalled = true
  }

  private(set) var closeFromManageCardViewerCalled = false
  func closeFromManageCardViewer() {
    closeFromManageCardViewerCalled = true
  }

  private(set) var accountSettingsTappedInManageCardViewerCalled = false
  func accountSettingsTappedInManageCardViewer() {
    accountSettingsTappedInManageCardViewerCalled = true
  }

  private(set) var cardSettingsTappedInManageCardViewerCalled = false
  func cardSettingsTappedInManageCardViewer() {
    cardSettingsTappedInManageCardViewerCalled = true
  }

  private(set) var balanceTappedInManageCardViewerCalled = false
  func balanceTappedInManageCardViewer() {
    balanceTappedInManageCardViewerCalled = true
  }

  private(set) var showCardStatsTappedInManageCardViewerCalled = false
  func showCardStatsTappedInManageCardViewer() {
    showCardStatsTappedInManageCardViewerCalled = true
  }

  private(set) var showTransactionDetailsCalled = false
  private(set) var lastTransactionShown: Transaction?
  func showTransactionDetails(transaction: Transaction) {
    showTransactionDetailsCalled = true
    lastTransactionShown = transaction
  }

  private(set) var physicalActivationSucceedCalled = false
  func physicalActivationSucceed() {
    physicalActivationSucceedCalled = true
  }
}

class ManageCardInteractorSpy: ManageCardInteractorProtocol {
  private(set) var isShowDetailedCardActivityEnabledCalled = false
  var nextIsShowDetailedCardActivityEnabledResult = true
  func isShowDetailedCardActivityEnabled() -> Bool {
    isShowDetailedCardActivityEnabledCalled = true
    return nextIsShowDetailedCardActivityEnabledResult
  }

  private(set) var provideFundingSourceCalled = false
  private(set) var lastProvideFundingSourceForceRefresh: Bool?
  func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback) {
    provideFundingSourceCalled = true
    lastProvideFundingSourceForceRefresh = forceRefresh
  }

  private(set) var reloadCardCalled = false
  func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    reloadCardCalled = true
  }

  private(set) var loadCardInfoCalled = false
  func loadCardInfo(_ callback: @escaping Result<Card, NSError>.Callback) {
    loadCardInfoCalled = true
  }

  private(set) var activateCardCalled = false
  func activateCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    activateCardCalled = true
  }

  private(set) var provideTransactionsCalled = false
  private(set) var lastProvideTransactionFilters: TransactionListFilters?
  private(set) var lastProvideTransactionForceRefresh: Bool?
  func provideTransactions(filters: TransactionListFilters,
                           forceRefresh: Bool,
                           callback: @escaping Result<[Transaction], NSError>.Callback) {
    provideTransactionsCalled = true
    lastProvideTransactionFilters = filters
    lastProvideTransactionForceRefresh = forceRefresh
  }

  private(set) var activatePhysicalCardCalled = false
  private(set) var lastPhysicalCardActivationCode: String?
  func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    activatePhysicalCardCalled = true
    lastPhysicalCardActivationCode = code
  }

  private(set) var loadFundingSourcesCalled = false
  func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback) {
    loadFundingSourcesCalled = true
  }
}

class ManageCardInteractorFake: ManageCardInteractorSpy {
  var nextProvideFundingSourceResult: Result<Card, NSError>?
  override func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback) {
    super.provideFundingSource(forceRefresh: forceRefresh, callback: callback)

    if let result = nextProvideFundingSourceResult {
      callback(result)
    }
  }

  var nextReloadCardResult: Result<Card, NSError>?
  override func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    super.reloadCard(callback)

    if let result = nextReloadCardResult {
      callback(result)
    }
  }

  var nextLoadCardInfoResult: Result<Card, NSError>?
  override func loadCardInfo(_ callback: @escaping Result<Card, NSError>.Callback) {
    super.loadCardInfo(callback)

    if let result = nextLoadCardInfoResult {
      callback(result)
    }
  }

  var nextActivateCardResult: Result<Card, NSError>?
  override func activateCard(_ callback: @escaping Result<Card, NSError>.Callback) {
    super.activateCard(callback)

    if let result = nextActivateCardResult {
      callback(result)
    }
  }

  var nextProvideTransactionsResult: Result<[Transaction], NSError>?
  override func provideTransactions(filters: TransactionListFilters,
                                    forceRefresh: Bool,
                                    callback: @escaping Result<[Transaction], NSError>.Callback) {
    super.provideTransactions(filters: filters, forceRefresh: forceRefresh, callback: callback)

    if let result = nextProvideTransactionsResult {
      callback(result)
    }
  }

  var nextActivatePhysicalCardResult: Result<Void, NSError>?
  override func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    super.activatePhysicalCard(code: code, callback: callback)

    if let result = nextActivatePhysicalCardResult {
      callback(result)
    }
  }

  var nextLoadFundingSourcesResult: Result<[FundingSource], NSError>?
  override func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback) {
    super.loadFundingSources(callback: callback)

    if let result = nextLoadFundingSourcesResult {
      callback(result)
    }
  }
}

class ManageCardPresenterSpy: ManageCardPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ManageCardViewProtocol!
  var interactor: ManageCardInteractorProtocol!
  var router: ManageCardRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = ManageCardViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var previousTappedCalled = false
  func previousTapped() {
    previousTappedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var nextTappedCalled = false
  func nextTapped() {
    nextTappedCalled = true
  }

  private(set) var cardTappedCalled = false
  func cardTapped() {
    cardTappedCalled = true
  }

  private(set) var cardSettingsTappedCalled = false
  func cardSettingsTapped() {
    cardSettingsTappedCalled = true
  }

  private(set) var balanceTappedCalled = false
  func balanceTapped() {
    balanceTappedCalled = true
  }

  private(set) var activateCardTappedCalled = false
  func activateCardTapped() {
    activateCardTappedCalled = true
  }

  private(set) var showCardStatsTappedCalled = false
  func showCardStatsTapped() {
    showCardStatsTappedCalled = true
  }

  private(set) var refreshCardCalled = false
  func refreshCard() {
    refreshCardCalled = true
  }

  private(set) var refreshFundingSourceCalled = false
  func refreshFundingSource() {
    refreshFundingSourceCalled = true
  }

  private(set) var showCardInfoCalled = false
  func showCardInfo() {
    showCardInfoCalled = true
  }

  private(set) var hideCardInfoCalled = false
  func hideCardInfo() {
    hideCardInfoCalled = true
  }

  private(set) var reloadTappedCalled = false
  private(set) var lastShowSpinnerWhileReloading: Bool?
  func reloadTapped(showSpinner: Bool) {
    reloadTappedCalled = true
    lastShowSpinnerWhileReloading = showSpinner
  }

  private(set) var moreTransactionsTappedCalled = false
  func moreTransactionsTapped(completion: @escaping (Bool) -> Void) {
    moreTransactionsTappedCalled = true
  }

  private(set) var transactionSelectedCalled = false
  private(set) var lastTransactionSelectedIndexPath: IndexPath?
  func transactionSelected(indexPath: IndexPath) {
    transactionSelectedCalled = true
    lastTransactionSelectedIndexPath = indexPath
  }

  private(set) var activatePhysicalCardTappedCalled = false
  func activatePhysicalCardTapped() {
    activatePhysicalCardTappedCalled = true
  }
}

class ManageCardViewSpy: ViewControllerSpy, ManageCardViewProtocol {
  func show(error: Error) {
    show(error: error, uiConfig: ModelDataProvider.provider.uiConfig)
  }

  private(set) var requestPhysicalActivationCodeCalled = false
  func requestPhysicalActivationCode(completion: @escaping (_ code: String) -> Void) {
    requestPhysicalActivationCodeCalled = true
  }
}

class ManageCardViewFake: ManageCardViewSpy {
  var nextPhysicalCardActivationCode: String?
  override func requestPhysicalActivationCode(completion: @escaping (_ code: String) -> Void) {
    super.requestPhysicalActivationCode(completion: completion)

    if let code = nextPhysicalCardActivationCode {
      completion(code)
    }
  }
}
