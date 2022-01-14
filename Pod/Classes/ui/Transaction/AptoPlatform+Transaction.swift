import AptoSDK

public extension AptoPlatform {
    var transaction: TransactionModule {
        AptoTransactionModule()
    }
}

internal struct AptoTransactionModule: TransactionModule {}
