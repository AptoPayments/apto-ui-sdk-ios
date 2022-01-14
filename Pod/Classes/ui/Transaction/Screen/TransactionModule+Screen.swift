import AptoSDK

public extension TransactionModule {
    var screen: TransactionScreenProvider {
        AptoTransactionScreenProvider()
    }
}
