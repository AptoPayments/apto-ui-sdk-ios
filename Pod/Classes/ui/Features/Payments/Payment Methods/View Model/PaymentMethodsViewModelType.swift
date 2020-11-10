import Bond
import Foundation

enum PaymentMethodsViewState {
  case idle
  case loading
  case loaded([PaymentMethodItem])
  case error(Error)
}

protocol PaymentMethodsViewModelType {
  var input: PaymentMethodsViewModelInput { get }
  var output: PaymentMethodsViewModelOutput { get }
}
 
protocol PaymentMethodsViewModelInput {
  func viewDidLoad()
  func didTapOnClose()
}

protocol PaymentMethodsViewModelOutput {
  var state: Observable<PaymentMethodsViewState> { get }
}
