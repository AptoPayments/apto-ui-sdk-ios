//
// MonthlyStatementsReportInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 25/09/2019.
//

import Foundation
import AptoSDK

class MonthlyStatementsReportInteractor: MonthlyStatementsReportInteractorProtocol {
  private let month: Month
  private let downloaderProvider: FileDownloaderProvider
  private let aptoPlatform: AptoPlatformProtocol

  init(month: Month, downloaderProvider: FileDownloaderProvider, aptoPlatform: AptoPlatformProtocol) {
    self.month = month
    self.downloaderProvider = downloaderProvider
    self.aptoPlatform = aptoPlatform
  }

  func reportDate() -> (month: Int, year: Int) {
    return (month: month.month, year: month.year)
  }

  func downloadReport(callback: @escaping Result<URL, NSError>.Callback) {
    aptoPlatform.fetchMonthlyStatementReport(month: month.month, year: month.year) { [weak self] result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let report):
        self?.processReport(report, callback: callback)
      }
    }
  }

  func processReport(_ report: MonthlyStatementReport, callback: @escaping Result<URL, NSError>.Callback) {
    guard let urlString = report.downloadUrl, let url = URL(string: urlString),
          (report.urlExpirationDate?.timeIntervalSince1970 ?? 0) > Date().timeIntervalSince1970 else {
      callback(.failure(DownloadUrlExpiredError()))
      return
    }
    let localFilename = "statement-\(report.month)-\(report.year).pdf"
    let downloader = downloaderProvider.fileDownloader(url: url, localFilename: localFilename)
    downloader.download { result in
      switch result {
      case .failure(let error):
        callback(.failure(error))
      case .success(let url):
        callback(.success(url))
      }
    }
  }
}
