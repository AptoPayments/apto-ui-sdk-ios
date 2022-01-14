import AptoSDK

public struct TransactionDetailOptions {
    let transaction: Transaction
    let uiConfig: UIConfig
    let events: TransactionScreenEvents?

    public init(
        transaction: Transaction,
        uiConfig: UIConfig = .default,
        events: TransactionScreenEvents? = nil
    ) {
        self.transaction = transaction
        self.uiConfig = uiConfig
        self.events = events
    }
}
