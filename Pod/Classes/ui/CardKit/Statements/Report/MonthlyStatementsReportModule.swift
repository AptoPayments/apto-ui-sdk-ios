//
//  MonthlyStatementsReportModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

import Foundation
import AptoSDK

class MonthlyStatementsReportModule: UIModule, MonthlyStatementsReportModuleProtocol {
  private let statementReport: MonthlyStatementReport
  private var presenter: MonthlyStatementsReportPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, statementReport: MonthlyStatementReport) {
    self.statementReport = statementReport
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let stringUrl = statementReport.downloadUrl, let url = URL(string: stringUrl) else {
      completion(.failure(ServiceError(code: .internalIncosistencyError)))
      return
    }
    let localFilename = "statement-\(statementReport.month)-\(statementReport.year).pdf"
    let viewController = buildViewController(downloader: FileDownloaderImpl(url: url, localFilename: localFilename))
    completion(.success(viewController))
  }

  private func buildViewController(downloader: FileDownloader) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.monthlyStatementsReportPresenter()
    let interactor = serviceLocator.interactorLocator.monthlyStatementsReportInteractor(report: statementReport,
                                                                                        downloader: downloader)
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.monthlyStatementsReportView(presenter: presenter)
  }
}
