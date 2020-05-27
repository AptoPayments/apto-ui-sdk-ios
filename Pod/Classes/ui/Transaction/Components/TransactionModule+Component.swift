import AptoSDK

extension TransactionModule {
  public var component: TransactionComponentProvider {
    AptoTransactionComponentProvider()
  }
}
