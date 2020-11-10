//
// ManageCardContract.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

import AptoSDK
import Bond

protocol ManageCardRouterProtocol: class {
  func update(card newCard: Card)
  func closeFromManageCardViewer()
  func accountSettingsTappedInManageCardViewer()
  func cardSettingsTappedInManageCardViewer()
  func balanceTappedInManageCardViewer()
  func showCardStatsTappedInManageCardViewer()
  func showTransactionDetails(transaction: Transaction)
  func physicalActivationSucceed()
}

protocol ManageCardViewProtocol: ViewControllerProtocol {
  func showLoadingSpinner()
  func show(error: Error)
  func requestPhysicalActivationCode(completion: @escaping (_ code: String) -> Void)
}

typealias ManageCardViewControllerProtocol = ShiftViewController & ManageCardViewProtocol

protocol TransactionsProvider {
  func isShowDetailedCardActivityEnabled() -> Bool
  func provideTransactions(filters: TransactionListFilters, forceRefresh: Bool,
                           callback: @escaping Result<[Transaction], NSError>.Callback)
}

protocol ManageCardInteractorProtocol: TransactionsProvider {
  func provideFundingSource(forceRefresh: Bool, callback: @escaping Result<Card, NSError>.Callback)
  func reloadCard(_ callback: @escaping Result<Card, NSError>.Callback)
  func loadCardInfo(_ callback: @escaping Result<Card, NSError>.Callback)
  func activateCard(_ callback: @escaping Result<Card, NSError>.Callback)
  func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback)
  func loadFundingSources(callback: @escaping Result<[FundingSource], NSError>.Callback)
}

protocol ManageCardEventHandler: class {
  var viewModel: ManageCardViewModel { get }
  func viewLoaded()
  func closeTapped()
  func nextTapped()
  func cardTapped()
  func cardSettingsTapped()
  func balanceTapped()
  func activateCardTapped()
  func showCardStatsTapped()
  func refreshCard()
  func refreshFundingSource()
  func showCardInfo()
  func hideCardInfo()
  func reloadTapped(showSpinner: Bool)
  func moreTransactionsTapped(completion: @escaping (_ noMoreTransactions: Bool) -> Void)
  func transactionSelected(indexPath: IndexPath)
  func activatePhysicalCardTapped()
}

open class ManageCardViewModel {
  public let state: Observable<FinancialAccountState?> = Observable(nil)
  public let isActivateCardFeatureEnabled: Observable<Bool?> = Observable(nil)
  public let cardInfoVisible: Observable<Bool?> = Observable(false)
  public let card: Observable<Card?> = Observable(nil)
  public let cardNetwork: Observable<CardNetwork?> = Observable(nil)
  public let orderedStatus: Observable<OrderedStatus> = Observable(.received)
  public let fundingSource: Observable<FundingSource?> = Observable(nil)
  public let spendableToday: Observable<Amount?> = Observable(nil)
  public let nativeSpendableToday: Observable<Amount?> = Observable(nil)
  public let transactions: MutableObservableArray2D<String, Transaction> = MutableObservableArray2D(Array2D())
  public let transactionsLoaded: Observable<Bool> = Observable(false)
  public let cardStyle: Observable<CardStyle?> = Observable(nil)
  public let cardLoaded: Observable<Bool> = Observable(false)
  public let showPhysicalCardActivationMessage: Observable<Bool> = Observable(true)
  public let isStatsFeatureEnabled: Observable<Bool> = Observable(false)
  public let isAccountSettingsEnabled: Observable<Bool> = Observable(true)
}

protocol ManageCardPresenterProtocol: ManageCardEventHandler {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ManageCardViewProtocol! { get set }
  var interactor: ManageCardInteractorProtocol! { get set }
  var router: ManageCardRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ManageCardViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }
}

struct ManageCardPresenterConfig {
  let name: String?
  let imageUrl: String?
  let showActivateCardButton: Bool?
  let showStatsButton: Bool?
  let showAccountSettingsButton: Bool?
}
