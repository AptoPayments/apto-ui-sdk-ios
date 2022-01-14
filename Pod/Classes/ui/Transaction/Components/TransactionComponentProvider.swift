import AptoSDK

public protocol TransactionComponentProvider {
    // MARK: - Transaction List

    /**
     `TransactionListView` component is in charge of getting the list of transactions from a `Card`,
     you can place this component anywhere in your app as long as
     you are logged in with our Core SDK. There's an options entity with extra parameters to configure
     the `TransactionListView`

     ```
     let apto = AptoPlatform.defaultManager()
     let options = TransactionListOptions(...)
     let transactionListView = apto.transaction.component.makeTransactionList(with: options)
     ```
     */
    func makeTransactionList(with options: TransactionListOptions) -> TransactionListView

    // MARK: - Card

    /**
     If you want to work with the `CreditCardView` it's pretty simple to do so,
     we only need to call the `makeCardView()` method    and a new `CreditCardView` component will be created.
     There are some options that you can pass to the component that can be found in
     the `CardViewOptions` entity. Here's a little example on how to generate a new `CreditCardView`

     ```
     let apto = AptoPlatform.defaultManager()
     let card = apto.transaction.component.makeCardView()
     ```

     ![Card](../../../../Assets/card_test.png)
     */
    func makeCardView() -> CreditCardView

    /**
     If you want to work with the `CreditCardView` it's pretty simple to do so, we only
     need to call the `makeCardView()` method    and a new `CreditCardView` component will be created.
     There are some options that you can pass to the component that can be found in
     the `CardViewOptions` entity. Here's a little example on how to generate a new `CreditCardView`

     ```
     let apto = AptoPlatform.defaultManager()
     let options = CardViewOptions(...)
     let card = apto.transaction.component.makeCardView(with: options)
     ```

     ![Card](../../../../Assets/card_test.png)
     */
    func makeCardView(with options: CardViewOptions) -> CreditCardView
}
