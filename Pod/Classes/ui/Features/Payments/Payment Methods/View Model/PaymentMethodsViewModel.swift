import AptoSDK
import Bond
import ReactiveKit
import UIKit

private typealias ViewModel = PaymentMethodsViewModelType & PaymentMethodsViewModelInput & PaymentMethodsViewModelOutput

final class PaymentMethodsViewModel: ViewModel {
    var input: PaymentMethodsViewModelInput { self }
    var output: PaymentMethodsViewModelOutput { self }
    var selectedPaymentMethod: PaymentMethodItem?

    private let apto: AptoPlatformProtocol
    private let mapper: PaymentSourceMapper
    private let notificationCenter: NotificationCenter
    private let disposeBag = DisposeBag()

    init(apto: AptoPlatformProtocol = AptoPlatform.defaultManager(),
         mapper: PaymentSourceMapper = .init(),
         notificationCenter: NotificationCenter = .default)
    {
        self.apto = apto
        self.mapper = mapper
        self.notificationCenter = notificationCenter
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    var navigator: PaymentMethodsNavigatorType?

    // MARK: - Output

    var state = Observable<PaymentMethodsViewState>(.idle)

    // MARK: - Input

    func viewDidLoad() {
        refreshPaymentMethods()
        listenNotifications()
    }

    func didTapOnClose() {
        navigator?.close()
    }

    private func listenNotifications() {
        notificationCenter
            .reactive
            .notification(name: .shouldRefreshPaymentMethods)
            .observeNext { [weak self] notification in
                guard let defaultSelectedItem = notification
                    .userInfo?["selectedItem"] as? PaymentMethodItem
                else {
                    self?.clearDefaultSelection()
                    self?.refreshPaymentMethods()
                    return
                }
                self?.selectedPaymentMethod = defaultSelectedItem
            }.dispose(in: disposeBag)
    }

    private func refreshPaymentMethods() {
        state.send(.loading)
        getPaymentSources()
    }

    private func getPaymentSources() {
        apto.getPaymentSources(.default) { [weak self] result in
            switch result {
            case let .success(paymentSources):
                self?.handle(paymentSources)
            case let .failure(error):
                self?.state.send(.error(error))
            }
        }
    }

    private func deletePaymentMethod(paymentSourceId: String) {
        state.send(.loading)
        apto.deletePaymentSource(paymentSourceId: paymentSourceId) { [weak self] result in
            switch result {
            case .success:
                self?.refreshPaymentMethods()
            case let .failure(error):
                self?.state.send(.error(error))
            }
        }
    }

    // swiftlint:disable trailing_closure
    private func handle(_ paymentMethods: [PaymentSource]) {
        let addCardItem = PaymentMethodItem(id: "add_card",
                                            type: .addCard,
                                            title: "load_funds.add_card.primary_cta".podLocalized(),
                                            subtitle: "load_funds.add_card.secondary_cta".podLocalized(),
                                            icon: .imageFromPodBundle("credit_debit_card"),
                                            action: { [weak self] _ in
                                                self?.navigator?.didTapOnAddCard()
                                            })
        var items: [PaymentMethodItem] = []
        var newPaymentMethod: PaymentMethodItem? {
            didSet {
                guard let newValue = newPaymentMethod else { return }

                selectedPaymentMethod = newValue
                self.state.send(.loaded(makeDefaultSelection(items: items)))
                self.notificationCenter.post(name: .shouldRefreshPaymentMethods,
                                             object: nil,
                                             userInfo: ["selectedItem": newValue])
                navigator?.close()
            }
        }
        items = mapper.map(elements: paymentMethods, action: { item in
            newPaymentMethod = PaymentMethodItem(id: item.id,
                                                 type: item.type,
                                                 title: item.title,
                                                 subtitle: item.subtitle,
                                                 isSelected: true,
                                                 icon: item.icon,
                                                 action: item.action)
        }, deleteAction: { item in
            self.deletePaymentMethodConfirm(item: item)
        })

        items.append(addCardItem)

        state.send(.loaded(makeDefaultSelection(items: items)))
    }

    // swiftlint:enable trailing_closure

    private func clearDefaultSelection() {
        selectedPaymentMethod = nil
    }

    private func makeDefaultSelection(items: [PaymentMethodItem]) -> [PaymentMethodItem] {
        items.map { [selectedPaymentMethod] item in
            guard let selectedPaymentMethod = selectedPaymentMethod else { return item }
            return PaymentMethodItem(id: item.id,
                                     type: item.type,
                                     title: item.title,
                                     subtitle: item.subtitle,
                                     isSelected: selectedPaymentMethod.id == item.id,
                                     icon: item.icon,
                                     action: item.action,
                                     deleteAction: item.deleteAction)
        }
    }

    private func deletePaymentMethodConfirm(item: PaymentMethodItem) {
        UIAlertController.confirm(title: "load_funds.payment_methods.delete_dialog.title".podLocalized(),
                                  message: "load_funds.payment_methods.delete_dialog.message".podLocalized(),
                                  okTitle: "load_funds.payment_methods.delete_dialog.cta".podLocalized(),
                                  cancelTitle: "load_funds.payment_methods.delete_dialog.cancel"
                                      .podLocalized()) { [weak self] action in
            if action.title == "load_funds.payment_methods.delete_dialog.cta".podLocalized() {
                self?.deletePaymentMethod(paymentSourceId: item.id)
            }
        }
    }
}
