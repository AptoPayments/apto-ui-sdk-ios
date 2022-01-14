import AptoSDK

public typealias OnTapOnTransaction = ((Transaction) -> Void)

public struct TransactionListEvents {
    public let onTapOnTransaction: OnTapOnTransaction?

    public init(onTapOnTransaction: OnTapOnTransaction? = nil) {
        self.onTapOnTransaction = onTapOnTransaction
    }
}
