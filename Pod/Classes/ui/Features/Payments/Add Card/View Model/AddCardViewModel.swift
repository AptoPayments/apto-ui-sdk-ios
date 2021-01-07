import Foundation
import Bond
import AptoSDK

private typealias ViewModel = AddCardViewModelType & AddCardViewModelInput & AddCardViewModelOutput

final class AddCardViewModel: ViewModel {
  var input: AddCardViewModelInput { self }
  var output: AddCardViewModelOutput { self }
  
  // MARK: - Collaborators
  
  private let aptoPlatform: AptoPlatformProtocol
  private let cardDetector: CardDetector
  private let expirationDateValidator: ExpirationDateValidator
  private let notificationCenter: NotificationCenter
  private var cardNetworks: [CardNetwork]
  var navigator: AddCardNavigatorType?
    private var userDefaults = UserDefaults.standard
  
  init(aptoPlatform: AptoPlatformProtocol = AptoPlatform.defaultManager(),
       cardDtector: CardDetector = .init(),
       expirationDateValidator: ExpirationDateValidator = .init(),
       notificationCenter: NotificationCenter = .default,
       cardNetworks: [CardNetwork] = [])
  {
    self.aptoPlatform = aptoPlatform
    self.cardDetector = cardDtector
    self.expirationDateValidator = expirationDateValidator
    self.notificationCenter = notificationCenter
    self.cardNetworks = cardNetworks
  }
 
  // MARK: - Output
  
  var addCardButtonEnabled = Observable<Bool>(false)
  var state = Observable<AddCardViewState>(.idle)
  
  // MARK: - Input
  
  private var card: String?
  private var cardType: CardType?
  
  func didChange(card: String, with type: CardType) {
    self.card = card
    self.cardType = type
    validateCard()
  }
  
  private var expirationDate: String?
  func didChange(expiration date: String) {
    self.expirationDate = date
    validateCard()
  }
  
  private var cvv: String?
  func didChange(cvv: String) {
    self.cvv = cvv
    validateCard()
  }
  
  private var zipCode: String?
  func didChange(zipCode: String) {
    self.zipCode = zipCode
    validateCard()
  }
  
  func didTapOnClose() {
    navigator?.close()
  }
  
  func didTapOnAddCard() {
    guard let cardRequest = self.cardRequest else { return }
    
    state.send(.loading)
    aptoPlatform.addPaymentSource(with: .card(cardRequest)) { [weak self] result in
      switch result {
      case .success:
        self?.notificationCenter.post(name: .shouldRefreshPaymentMethods, object: nil)
        self?.state.send(.idle)
        self?.navigator?.close()
      case .failure(let error):
        self?.state.send(.error(error))
      }
    }
  }
  
  private var cardRequest: PaymentSourceCardRequest? {
    guard let card = self.card?.replacingOccurrences(of: " ", with: ""),
      let expirationDate = self.expirationDate,
      let (month, year) = expirationDateValidator.extractDate(from: expirationDate),
      let cvv = self.cvv, !cvv.isEmpty,
      let zipCode = self.zipCode, !zipCode.isEmpty else {
        return nil
    }
    let formattedExpiration = "\(String(format: "%02d", year))-\(String(format: "%02d", month))"
    return PaymentSourceCardRequest(pan: card, cvv: cvv, expirationDate: formattedExpiration, zipCode: zipCode)
  }
  
  private func validateCard() {
    guard let card = self.card,
      let expirationDate = self.expirationDate,
      let cvv = self.cvv, !cvv.isEmpty,
      let zipCode = self.zipCode, !zipCode.isEmpty else {
        self.disableAddCardButton()
        return
    }
    
    guard case (_, true) = cardDetector.detect(card, cardNetworks: cardNetworks) else {
      self.disableAddCardButton()
      return
    }
    
    guard expirationDateValidator.validate(expirationDate) else {
      self.disableAddCardButton()
      return
    }
    self.enableAddCardButton()
  }
  
  private func disableAddCardButton() {
    addCardButtonEnabled.send(false)
  }
  
  private func enableAddCardButton() {
    addCardButtonEnabled.send(true)
  }
}
