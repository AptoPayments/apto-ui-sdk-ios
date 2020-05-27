import AptoSDK
 
internal struct AptoTransactionScreenProvider: TransactionScreenProvider {
  
  private let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared,
       uiConfig: UIConfig)
  {
    self.serviceLocator = serviceLocator
    self.serviceLocator.uiConfig = uiConfig
  }
  
  func details(with transaction: Transaction,
               screenEvents: TransactionScreenEvents) -> UIViewController
  {
    build(with: transaction, screenEvents: screenEvents)
  }
  
  func details(with transaction: Transaction) -> UIViewController {
    build(with: transaction)
  }
  
  private func build(with transaction: Transaction,
                     screenEvents: TransactionScreenEvents? = nil) -> UIViewController
  {
    let presenter = serviceLocator.presenterLocator.transactionDetailsPresenter()
    let interactor = serviceLocator.interactorLocator.transactionDetailsInteractor(transaction: transaction)
    let viewController = serviceLocator.viewLocator.transactionDetailsView(presenter: presenter)
    
    presenter.interactor = interactor
    presenter.router = TransactionDetailRouter(
      screenEvents: screenEvents
    )
    presenter.view = viewController
    presenter.analyticsManager = serviceLocator.analyticsManager
    return viewController
  }
}
