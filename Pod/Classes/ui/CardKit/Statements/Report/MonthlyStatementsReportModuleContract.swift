//
//  MonthlyStatementsReportModuleContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

import AptoSDK
import Bond

protocol MonthlyStatementsReportModuleProtocol: UIModuleProtocol {
}

protocol FileDownloader {
  func download(callback: @escaping Result<URL, NSError>.Callback)
}

protocol MonthlyStatementsReportInteractorProtocol {
  func reportDate() -> (month: Int, year: Int)
  func downloadReport(callback: @escaping Result<URL, NSError>.Callback)
}

class MonthlyStatementsReportViewModel {
  let url: Observable<URL?> = Observable(nil)
  let month: Observable<String> = Observable("")
  let year: Observable<String> = Observable("")
  let error: Observable<NSError?> = Observable(nil)
}

protocol MonthlyStatementsReportPresenterProtocol: class {
  var router: MonthlyStatementsReportModuleProtocol? { get set }
  var interactor: MonthlyStatementsReportInteractorProtocol? { get set }
  var viewModel: MonthlyStatementsReportViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
}

class DownloadUrlExpiredError: NSError {
  private let errorDomain = "com.aptopayments.statements.download.timeout"
  private let errorCode = 4444

  init() {
    let userInfo = [NSLocalizedDescriptionKey: "monthly_statements.report.error_url_expired.message".podLocalized()]
    super.init(domain: errorDomain, code: errorCode, userInfo: userInfo)
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
