import AptoSDK

public protocol TransactionScreenProvider {
  func details(with transaction: Transaction, screenEvents: TransactionScreenEvents) -> UIViewController
  func details(with transaction: Transaction) -> UIViewController
}
