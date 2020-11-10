import Bond
import Foundation

enum AddCardViewState {
  case idle
  case loading
  case error(Error)
}

protocol AddCardViewModelType {
  var input: AddCardViewModelInput { get }
  var output: AddCardViewModelOutput { get }
}

protocol AddCardViewModelInput {
  func didChange(card: String, with type: CardType)
  func didChange(expiration date: String)
  func didChange(cvv: String)
  func didChange(zipCode: String)
  
  func didTapOnAddCard()
  func didTapOnClose()
}

protocol AddCardViewModelOutput {
  var state: Observable<AddCardViewState> { get }
  var addCardButtonEnabled: Observable<Bool> { get }
}
