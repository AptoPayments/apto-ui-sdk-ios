import AptoSDK

extension TransactionModule {
  public var screen: TransactionScreenProvider {
    AptoTransactionScreenProvider()
  }
}
