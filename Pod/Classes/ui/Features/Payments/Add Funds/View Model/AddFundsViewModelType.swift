import AptoSDK
import Bond
import UIKit

enum AddFundsViewState {
    case idle
    case loading
    case loaded(PaymentSource?)
    case alert(UIAlertController)
    case error(Error)
}

protocol AddFundsViewModelType {
    var input: AddFundsViewModelInput { get }
    var output: AddFundsViewModelOutput { get }
    var exceedsDailyLimitsAmount: ((Double) -> Void)? { get set }
}

protocol AddFundsViewModelInput {
    func viewDidLoad()
    func didChangeAmount(value: String?)
    func didTapOnChangeCard()
    func didTapOnPullFunds()
}

protocol AddFundsViewModelOutput {
    var state: Observable<AddFundsViewState> { get }
    var nextButtonEnabled: Observable<Bool> { get }
}
