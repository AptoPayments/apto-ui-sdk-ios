//
//  MonthlyStatementsReportInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class MonthlyStatementsReportInteractorTest: XCTestCase {
  private var sut: MonthlyStatementsReportInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let report = ModelDataProvider.provider.monthlyStatementReport
  private let downloader = FileDownloaderFake()

  override func setUp() {
    super.setUp()
    sut = MonthlyStatementsReportInteractor(report: report, downloader: downloader)
  }

  func testReportDateReturnMonthAndYear() {
    // When
    let reportDate = sut.reportDate()

    // Then
    XCTAssertEqual(report.month, reportDate.month)
    XCTAssertEqual(report.year, reportDate.year)
  }

  func testDownloadReportWithExpiredDownloadUrlCallbackDownloadURLExpired() {
    // Given
    sut = MonthlyStatementsReportInteractor(report: ModelDataProvider.provider.monthlyStatementReportExpired,
                                            downloader: downloader)

    // When
    sut.downloadReport { result in
      // Then
      XCTAssertTrue(result.isFailure)
      XCTAssertTrue(result.error is DownloadUrlExpiredError)
    }
  }

  func testDownloadReportWithoutExpirationCallbackDownloadURLExpired() {
    // Given
    sut = MonthlyStatementsReportInteractor(report: ModelDataProvider.provider.monthlyStatementReportWithoutExpiration,
                                            downloader: downloader)

    // When
    sut.downloadReport { result in
      // Then
      XCTAssertTrue(result.isFailure)
      XCTAssertTrue(result.error is DownloadUrlExpiredError)
    }
  }

  func testDownloadReportCallFileDownloader() {
    // When
    sut.downloadReport { _ in }

    // Then
    XCTAssertTrue(downloader.downloadCalled)
  }

  func testDownloadReportSucceedCallbackSuccess() {
    // Given
    let url = URL(string: "https://aptopayments.com")! // swiftlint:disable:this force_unwrapping
    downloader.nextDownloadResult = .success(url)

    // When
    sut.downloadReport { result in
      // Then
      XCTAssertTrue(result.isSuccess)
      XCTAssertEqual(url, result.value)
    }
  }

  func testDownloadReportFailsCallbackFailure() {
    // Given
    let error = BackendError(code: .other)
    downloader.nextDownloadResult = .failure(error)

    // When
    sut.downloadReport { result in
      // Then
      XCTAssertTrue(result.isFailure)
      XCTAssertEqual(error, result.error)
    }
  }
}
