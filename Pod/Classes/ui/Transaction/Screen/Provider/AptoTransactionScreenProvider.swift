import AptoSDK
 
internal struct AptoTransactionScreenProvider: TransactionScreenProvider {
  
  private let serviceLocator: ServiceLocatorProtocol

  init(serviceLocator: ServiceLocatorProtocol = ServiceLocator.shared) {
    self.serviceLocator = serviceLocator
  }
  
  func details(with options: TransactionDetailOptions) -> UIViewController {
    build(with: options.transaction, screenEvents: options.events)
  }
  
  private func build(with transaction: Transaction,
                     screenEvents: TransactionScreenEvents? = nil,
                     uiConfig: UIConfig = .default) -> UIViewController
  {
    let presenter = serviceLocator.presenterLocator.transactionDetailsPresenter()
    let interactor = serviceLocator.interactorLocator.transactionDetailsInteractor(transaction: transaction)
    let viewController = serviceLocator.viewLocator.transactionDetailsView(presenter: presenter)
    
    serviceLocator.uiConfig = AptoPlatform.defaultManager().fetchUIConfig() ?? uiConfig
    
    presenter.interactor = interactor
    presenter.router = TransactionDetailRouter(
      screenEvents: screenEvents
    )
    presenter.view = viewController
    presenter.analyticsManager = serviceLocator.analyticsManager
    return viewController
  }
}
