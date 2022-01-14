//
//  MonthlyStatementsReportInteractorTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class MonthlyStatementsReportInteractorTest: XCTestCase {
    private var sut: MonthlyStatementsReportInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let month = ModelDataProvider.provider.month
    private let downloaderProvider = SystemServicesLocatorFake()
    private let platform = AptoPlatformFake()
    private let dataProvider = ModelDataProvider.provider
    private lazy var downloader = downloaderProvider.fileDownloaderFake

    override func setUp() {
        super.setUp()
        sut = MonthlyStatementsReportInteractor(month: month, downloaderProvider: downloaderProvider,
                                                aptoPlatform: platform)
    }

    func testReportDateReturnMonthAndYear() {
        // When
        let reportDate = sut.reportDate()

        // Then
        XCTAssertEqual(month.month, reportDate.month)
        XCTAssertEqual(month.year, reportDate.year)
    }

    func testDownloadReportCallPlatform() {
        // When
        sut.downloadReport { _ in }

        // Then
        XCTAssertTrue(platform.fetchMonthlyStatementReportCalled)
    }

    func testFetchReportFailsCallbackFailure() {
        // Given
        platform.nextFetchMonthlyStatementReportResult = .failure(BackendError(code: .other))

        // When
        sut.downloadReport { result in
            // Then
            XCTAssertTrue(result.isFailure)
        }
    }

    func testFetchReportReturnReportWithoutUrlCallbackError() {
        // Given
        platform.nextFetchMonthlyStatementReportResult = .success(dataProvider.monthlyStatementReportWithoutUrl)

        // When
        sut.downloadReport { result in
            // Then
            XCTAssertTrue(result.isFailure)
            XCTAssertTrue(result.error is DownloadUrlExpiredError)
        }
    }

    func testFetchReportReturnReportWithoutExpirationCallbackError() {
        // Given
        platform.nextFetchMonthlyStatementReportResult = .success(dataProvider.monthlyStatementReportWithoutExpiration)

        // When
        sut.downloadReport { result in
            // Then
            XCTAssertTrue(result.isFailure)
            XCTAssertTrue(result.error is DownloadUrlExpiredError)
        }
    }

    func testFetchReportReturnReportExpiredCallbackError() {
        // Given
        platform.nextFetchMonthlyStatementReportResult = .success(dataProvider.monthlyStatementReportExpired)

        // When
        sut.downloadReport { result in
            // Then
            XCTAssertTrue(result.isFailure)
            XCTAssertTrue(result.error is DownloadUrlExpiredError)
        }
    }

    func testFetchReportSucceedCallDownloader() {
        givenFetchStatementReportSucceed()

        // When
        sut.downloadReport { _ in }

        // Then
        XCTAssertTrue(downloader.downloadCalled)
    }

    func testDownloadFailCallbackFailure() {
        // Given
        givenFetchStatementReportSucceed()
        downloader.nextDownloadResult = .failure(BackendError(code: .other))

        // When
        sut.downloadReport { result in
            // Then
            XCTAssertTrue(result.isFailure)
        }
    }

    func testDownloadSucceedCallbackSuccess() {
        // Given
        givenFetchStatementReportSucceed()
        let url = dataProvider.url
        downloader.nextDownloadResult = .success(url)

        // When
        sut.downloadReport { result in
            // Then
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(url, result.value)
        }
    }

    // MARK: - Private helpers

    private func givenFetchStatementReportSucceed() {
        // Given
        platform.nextFetchMonthlyStatementReportResult = .success(dataProvider.monthlyStatementReport)
    }
}
