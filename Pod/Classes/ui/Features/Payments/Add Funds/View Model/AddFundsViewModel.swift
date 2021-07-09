import Bond
import AptoSDK
import ReactiveKit

private typealias ViewModel = AddFundsViewModelInput & AddFundsViewModelOutput & AddFundsViewModelType

final class AddFundsViewModel: ViewModel {
  
  var input: AddFundsViewModelInput { self }
  var output: AddFundsViewModelOutput { self }
    var exceedsDailyLimitsAmount: ((Double) -> Void)?

  var navigator: AddFundsNavigatorType?
  
  private let apto: AptoPlatformProtocol
  private let card: Card
  private let formatter: NumberFormatter
  private let notificationCenter: NotificationCenter
  private let disposeBag = DisposeBag()
  
  private var currentPaymentSource: PaymentSource?
  private var amount: Double?

  init(apto: AptoPlatformProtocol = AptoPlatform.defaultManager(),
       card: Card,
       formatter: NumberFormatter = .init(),
       notificationCenter: NotificationCenter = .default)
  {
    self.apto = apto
    self.card = card
    self.formatter = formatter
    self.notificationCenter = notificationCenter
  }
  
  deinit {
    notificationCenter.removeObserver(self)
  }
  
  // MARK: - Output
  
  var state = Observable<AddFundsViewState>(.idle)
  var nextButtonEnabled = Observable<Bool>(false)
  
  // MARK: - Input
  
  func viewDidLoad() {
    self.listenNotifications()
    self.fetchCurrentPaymentSource()
  }
  
  func didChangeAmount(value: String?) {
    guard self.currentPaymentSource != nil,
      let value = value,
      let amount = Double(value),
      amount > 0,
      let lastChar = value.last,
      lastChar != "." else
    {
      self.nextButtonEnabled.send(false)
      return
    }
    
    if let features = card.features, let fundings = features.funding {
        let limits = fundings.limits.daily
        if let max = limits.max.amount.value,
           amount > max {
            exceedsDailyLimitsAmount?(max)
            self.nextButtonEnabled.send(false)
            return
        }
    }
    
    self.amount = amount
    self.nextButtonEnabled.send(true)
  }
  
  func didTapOnChangeCard() {
    guard let currentPaymentSource = self.currentPaymentSource else {
      navigator?.navigateToAddCard()
      return
    }
    navigator?.navigateToPaymentMethods(defaultSelectedPaymentMethod: currentPaymentSource)
  }
  
  func didTapOnPullFunds() {
    self.state.send(.loading)

    guard let paymentSourceId = self.currentPaymentSource?.id,
      let balanceId = self.card.fundingSource?.fundingSourceId else {
      self.state.send(.idle)
      return
    }
    
    let request = PushFundsRequest(
      paymentSourceId: paymentSourceId,
      balanceId: balanceId,
      amount: Amount(
        value: self.amount,
        currency: self.card.fundingSource?.balance?.currency.value
      )
    )
    self.pushFunds(with: request)
  }
  
  private func pushFunds(with request: PushFundsRequest) {
    self.apto.pushFunds(with: request) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let paymentResult):
        self.state.send(.idle)
        self.handle(paymentResult)
      case .failure(let error):
        self.state.send(.error(error))
      }
    }
  }
  
  private func handle(_ paymentResult: PaymentResult) {
    switch paymentResult.status {
    case .failed:
      self.state.send(.alert(failedTransactionAlert))
    default:
      self.navigator?.navigateToPaymentResult(with: paymentResult, and: paymentResult.source)
    }
  }
  
  private func listenNotifications() {
    notificationCenter.reactive.notification(name: .shouldRefreshPaymentMethods).observeNext { [weak self] notification in
      guard let selectedItem = notification.userInfo?["selectedItem"] as? PaymentMethodItem else {
          self?.fetchCurrentPaymentSource()
          return
        }
        self?.fetchCurrentPaymentSource(selectedItem: selectedItem.id)
    }.dispose(in: disposeBag)
  }
  
  private func fetchCurrentPaymentSource(selectedItem: String = "") {
    self.state.send(.loading)
    self.apto.getPaymentSources(.default) { [weak self] result in
        guard let self = self else { return }
      switch result {
      case .success(let paymentSources):
        self.currentPaymentSource = self.extractAvailableSource(with: paymentSources, selectedItem: selectedItem)
        self.state.send(.loaded(self.currentPaymentSource))
        
      case .failure(let error):
        self.state.send(.error(error))
      }
    }
  }
  
    private func extractAvailableSource(with paymentSources: [PaymentSource], selectedItem: String) -> PaymentSource? {
        return paymentSources.first(where: { paymentSource in
            if case .card(let card) = paymentSource {
                return selectedItem != "" ? card.id == selectedItem : card.isPreferred
            }
            return false
        })
    }
    
  // MARK: - Alerts
  
  private var failedTransactionAlert: UIAlertController {
    let alertController = UIAlertController(title: "load_funds_add_money_error_title".podLocalized(), message: "load_funds_add_money_error_message".podLocalized(), preferredStyle: .alert)
    let okAction = UIAlertAction(title: "load_funds_add_money_error_action".podLocalized(), style: .cancel, handler: nil)
    alertController.addAction(okAction)
    return alertController
  }
}
