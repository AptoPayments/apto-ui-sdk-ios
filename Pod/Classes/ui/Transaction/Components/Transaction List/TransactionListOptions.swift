import AptoSDK

public struct TransactionListOptions {
  public let card: Card
  public let uiConfig: UIConfig
  public let events: TransactionListEvents?
  public let config: TransactionListModuleConfig?
  
  public init(
    card: Card,
    uiConfig: UIConfig = .default,
    events: TransactionListEvents? = nil,
    config: TransactionListModuleConfig? = nil)
  {
    self.card = card
    self.uiConfig = uiConfig
    self.events = events
    self.config = config
  }
}
