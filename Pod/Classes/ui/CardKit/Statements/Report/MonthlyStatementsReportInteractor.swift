//
// MonthlyStatementsReportInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 25/09/2019.
//

import Foundation
import AptoSDK

class MonthlyStatementsReportInteractor: MonthlyStatementsReportInteractorProtocol {
  private let report: MonthlyStatementReport
  var downloader: FileDownloader

  init(report: MonthlyStatementReport, downloader: FileDownloader) {
    self.report = report
    self.downloader = downloader
  }

  func reportDate() -> (month: Int, year: Int) {
    return (month: report.month, year: report.year)
  }

  func downloadReport(callback: @escaping Result<URL, NSError>.Callback) {
    guard (report.urlExpirationDate?.timeIntervalSince1970 ?? 0) > Date().timeIntervalSince1970 else {
      callback(.failure(DownloadUrlExpiredError()))
      return
    }
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
