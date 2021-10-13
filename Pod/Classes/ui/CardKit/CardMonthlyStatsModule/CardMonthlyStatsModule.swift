//
//  CardMonthlyStatsModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/01/2019.
//

import Foundation
import AptoSDK

class CardMonthlyStatsModule: UIModule, CardMonthlyStatsModuleProtocol {
  private let card: Card
  private var presenter: CardMonthlyStatsPresenterProtocol?
  private var transactionListModule: TransactionListModuleProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card) {
    self.card = card
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  func showTransactions(for categorySpending: CategorySpending, startDate: Date, endDate: Date) {
    let config = TransactionListModuleConfig(startDate: startDate,
                                             endDate: endDate,
                                             categoryId: categorySpending.categoryId)
    let module = serviceLocator.moduleLocator.transactionListModule(card: card, config: config)
    module.onClose = { [weak self] _ in
      self?.popModule {
        self?.transactionListModule = nil
      }
    }
    self.transactionListModule = module
    push(module: module) { _ in }
  }

  func showStatementReport(month: Month) {
    let module = serviceLocator.moduleLocator.monthlyStatementsReportModule(month: month)
    module.onClose = { [weak self] _ in
      self?.popModule {}
    }
    push(module: module) { _ in }
  }

  // MARK: - Private methods
  private func buildViewController() -> AptoViewController {
    let presenter = serviceLocator.presenterLocator.cardMonthlyStatsPresenter()
    let interactor = serviceLocator.interactorLocator.cardMonthlyStatsInteractor(card: card)
    let viewController = serviceLocator.viewLocator.cardMonthlyView(presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }
}
