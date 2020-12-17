import Foundation
import AptoSDK

class SetPassCodeInteractor: SetCodeInteractorProtocol {
  private let platform: AptoPlatformProtocol
  private let card: Card
  private let verification: Verification?

  init(platform: AptoPlatformProtocol, card: Card, verification: Verification?) {
    self.platform = platform
    self.card = card
    self.verification = verification
  }

  func changeCode(_ code: String, completion: @escaping Result<Card, NSError>.Callback) {
    platform.setCardPassCode(card.accountId, passCode: code, verificationId: verification?.verificationId) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success:
        completion(.success(self.card))
      }
    }
  }
}
