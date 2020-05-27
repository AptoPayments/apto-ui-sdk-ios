import AptoSDK

extension TransactionModule {
  public var screen: TransactionScreenProvider {
    AptoTransactionScreenProvider(
      uiConfig: AptoPlatform.defaultManager().fetchUIConfig() ?? .default
    )
  }
}
