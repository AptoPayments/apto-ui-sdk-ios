import AptoSDK
import Bond
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
        listenNotifications()
        fetchCurrentPaymentSource()
    }

    func didChangeAmount(value: String?) {
        let decimalSeparator: String = NSLocale.current.decimalSeparator ?? "."

        guard currentPaymentSource != nil,
              let value = value,
              let amount = Double(value),
              amount > 0,
              let lastChar = value.last,
              lastChar != Character(decimalSeparator)
        else {
            nextButtonEnabled.send(false)
            return
        }

        if let features = card.features, let fundings = features.funding {
            let limits = fundings.limits.daily
            if let max = limits.max.amount.value,
               amount > max
            {
                exceedsDailyLimitsAmount?(max)
                nextButtonEnabled.send(true)
                return
            }
        }

        self.amount = amount
        nextButtonEnabled.send(true)
    }

    func didTapOnChangeCard() {
        guard let currentPaymentSource = currentPaymentSource else {
            navigator?.navigateToAddCard()
            return
        }
        navigator?.navigateToPaymentMethods(defaultSelectedPaymentMethod: currentPaymentSource)
    }

    func didTapOnPullFunds() {
        state.send(.loading)

        guard let paymentSourceId = currentPaymentSource?.id,
              let balanceId = card.fundingSource?.fundingSourceId
        else {
            state.send(.idle)
            return
        }

        let request = PushFundsRequest(
            paymentSourceId: paymentSourceId,
            balanceId: balanceId,
            amount: Amount(
                value: amount,
                currency: card.fundingSource?.balance?.currency.value
            )
        )
        pushFunds(with: request)
    }

    private func pushFunds(with request: PushFundsRequest) {
        apto.pushFunds(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(paymentResult):
                self.state.send(.idle)
                self.handle(paymentResult)
            case let .failure(error):
                self.state.send(.error(error))
            }
        }
    }

    private func handle(_ paymentResult: PaymentResult) {
        switch paymentResult.status {
        case .failed:
            state.send(.alert(failedTransactionAlert))
        default:
            navigator?.navigateToPaymentResult(with: paymentResult, and: paymentResult.source)
        }
    }

    private func listenNotifications() {
        notificationCenter
            .reactive
            .notification(name: .shouldRefreshPaymentMethods)
            .observeNext { [weak self] notification in
                guard let selectedItem = notification.userInfo?["selectedItem"] as? PaymentMethodItem else {
                    self?.fetchCurrentPaymentSource()
                    return
                }
                self?.fetchCurrentPaymentSource(selectedItem: selectedItem.id)
            }.dispose(in: disposeBag)
    }

    private func fetchCurrentPaymentSource(selectedItem: String = "") {
        state.send(.loading)
        apto.getPaymentSources(.default) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(paymentSources):
                self.currentPaymentSource = self.extractAvailableSource(with: paymentSources, selectedItem: selectedItem)
                self.state.send(.loaded(self.currentPaymentSource))

            case let .failure(error):
                self.state.send(.error(error))
            }
        }
    }

    private func extractAvailableSource(with paymentSources: [PaymentSource], selectedItem: String) -> PaymentSource? {
        // swiftlint:disable trailing_closure
        return paymentSources.first(where: { paymentSource in
            if case let .card(card) = paymentSource {
                return selectedItem != "" ? card.id == selectedItem : card.isPreferred
            }
            return false
        })
        // swiftlint:enable trailing_closure
    }

    // MARK: - Alerts

    private var failedTransactionAlert: UIAlertController {
        let alertController = UIAlertController(title: "load_funds_add_money_error_title".podLocalized(),
                                                message: "load_funds_add_money_error_message".podLocalized(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "load_funds_add_money_error_action".podLocalized(),
                                     style: .cancel, handler: nil)
        alertController.addAction(okAction)
        return alertController
    }
}
