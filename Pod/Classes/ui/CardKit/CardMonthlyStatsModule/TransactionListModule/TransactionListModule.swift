//
//  TransactionListModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/01/2019.
//

import Foundation
import AptoSDK
import MapKit

class TransactionListModule: UIModule, TransactionListModuleProtocol {
  private let card: Card
  private let config: TransactionListModuleConfig
  private var presenter: TransactionListPresenterProtocol?
  private var transactionDetailsPresenter: AptoCardTransactionDetailsPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card, config: TransactionListModuleConfig) {
    self.card = card
    self.config = config
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let presenter = serviceLocator.presenterLocator.transactionListPresenter(config: config)
    let interactor = serviceLocator.interactorLocator.transactionListInteractor(card: card)
    let viewController = serviceLocator.viewLocator.transactionListView(presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    completion(.success(viewController))
  }

  func showDetails(of transaction: Transaction) {
    let viewController = buildTransactionDetailsViewController(for: transaction, uiConfig: uiConfig)
    push(viewController: viewController) {}
  }

  // MARK: - Private methods
  private func buildTransactionDetailsViewController(for transaction: Transaction,
                                                     uiConfig: UIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.transactionDetailsPresenter()
    let interactor = serviceLocator.interactorLocator.transactionDetailsInteractor(transaction: transaction)
    let viewController = serviceLocator.viewLocator.transactionDetailsView(presenter: presenter)
    presenter.interactor = interactor
    presenter.router = self
    presenter.view = viewController
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.transactionDetailsPresenter = presenter
    return viewController
  }
}

extension TransactionListModule: AptoCardTransactionDetailsRouterProtocol {
  func backFromTransactionDetails() {
    popViewController {}
  }
}
