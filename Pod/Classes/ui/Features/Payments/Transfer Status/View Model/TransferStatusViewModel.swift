import Bond
import AptoSDK

private typealias ViewModel = TransferStatusViewModelType & TransferStatusViewModelInput & TransferStatusViewModelOutput

final class TransferStatusViewModel: ViewModel {
  var input: TransferStatusViewModelInput { self }
  var output: TransferStatusViewModelOutput { self }
  
  private let paymentResult: PaymentResult
  private let paymentSource: PaymentSource
  private let mapper: TransferStatusItemMapper
  private let softDescriptor: String?
  
  var navigator: TransferStatusNavigationType?
  
  init(paymentResult: PaymentResult,
       paymentSource: PaymentSource,
       softDescriptor: String?,
       mapper: TransferStatusItemMapper = .init())
  {
    self.paymentResult = paymentResult
    self.paymentSource = paymentSource
    self.mapper = mapper
    self.softDescriptor = softDescriptor
  }
  
  // MARK: - Output
  
  var state = Observable<TransferStatusViewState>(.idle)
  
  // MARK: - Input
  
  func viewDidLoad() {
    state.send(.loaded(
      items: self.mapper.map(paymentResult: paymentResult, paymentSource: paymentSource),
      amount: paymentResult.amount,
      softDescriptor: softDescriptor ?? ""
    ))
  }
  
  func didTapOnClose() {
    navigator?.close()
  }
}
