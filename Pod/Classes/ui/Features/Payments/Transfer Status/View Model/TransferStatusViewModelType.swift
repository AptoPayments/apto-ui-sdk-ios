import Bond
import AptoSDK

enum TransferStatusViewState {
  case idle
    case loaded(items: [TransferStatusItem], amount: Amount, softDescriptor: String)
}

protocol TransferStatusViewModelType {
  var input: TransferStatusViewModelInput { get }
  var output: TransferStatusViewModelOutput { get }
}

protocol TransferStatusViewModelInput {
  func viewDidLoad()
  func didTapOnClose()
}

protocol TransferStatusViewModelOutput {
  var state: Observable<TransferStatusViewState> { get }
}
