import AptoSDK

public protocol TransactionScreenProvider {
  /**
   Create a TransactionDetail view controller configured with extra parameters from `TransactionDetailOptions`
   
   ```
   let apto = AptoPlatform.defaultManager()
   let options = TransactionDetailOptions(...)
   let transactionDetail = apto.transaction.screen.details(with: options)
   ```
   */
  func details(with options: TransactionDetailOptions) -> UIViewController
}
