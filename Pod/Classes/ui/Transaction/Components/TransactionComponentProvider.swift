import AptoSDK

public protocol TransactionComponentProvider {
  
  // MARK: - Transaction List
  
  func makeTransactionList(with options: TransactionListOptions) -> TransactionListView
  
  // MARK: - Card

  func makeCardView() -> CreditCardView
  func makeCardView(with options: CardViewOptions) -> CreditCardView
}
