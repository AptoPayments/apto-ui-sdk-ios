//
//  MonthlyStatementsReportModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

import Foundation
import AptoSDK

class MonthlyStatementsReportModule: UIModule, MonthlyStatementsReportModuleProtocol {
  private let month: Month
  private var presenter: MonthlyStatementsReportPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, month: Month) {
    self.month = month
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.monthlyStatementsReportPresenter()
    let locator = serviceLocator.interactorLocator
    let interactor = locator.monthlyStatementsReportInteractor(month: month,
                                                               downloaderProvider: serviceLocator.systemServicesLocator)
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.monthlyStatementsReportView(presenter: presenter)
  }
}
