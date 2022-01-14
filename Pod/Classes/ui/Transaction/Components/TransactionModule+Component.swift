import AptoSDK

public extension TransactionModule {
    var component: TransactionComponentProvider {
        AptoTransactionComponentProvider()
    }
}
