//
//  MonthlyStatementsListModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 23/09/2019.
//

import Foundation
import AptoSDK

class MonthlyStatementsListModule: UIModule, MonthlyStatementsListModuleProtocol {
  private var presenter: MonthlyStatementsListPresenterProtocol?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    completion(.success(buildViewController()))
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.monthlyStatementsListPresenter()
    let interactor = serviceLocator.interactorLocator.monthlyStatementsListInteractor()
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.monthlyStatementsListView(presenter: presenter)
  }

  func showStatementReport(month: Month) {
    let module = serviceLocator.moduleLocator.monthlyStatementsReportModule(month: month)
    module.onClose = { [weak self] _ in
      self?.popModule {}
    }
    push(module: module) { _ in }
  }
}
