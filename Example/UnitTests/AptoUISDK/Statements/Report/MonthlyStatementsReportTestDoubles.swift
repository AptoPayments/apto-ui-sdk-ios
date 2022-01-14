//
//  MonthlyStatementsReportTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

@testable import AptoSDK
@testable import AptoUISDK

class MonthlyStatementsReportModuleSpy: UIModuleSpy, MonthlyStatementsReportModuleProtocol {}

class FileDownloaderSpy: FileDownloader {
    private(set) var downloadCalled = false
    func download(callback _: @escaping Result<URL, NSError>.Callback) {
        downloadCalled = true
    }
}

class FileDownloaderFake: FileDownloaderSpy {
    var nextDownloadResult: Result<URL, NSError>?
    override func download(callback: @escaping Result<URL, NSError>.Callback) {
        super.download(callback: callback)
        if let result = nextDownloadResult {
            callback(result)
        }
    }
}

class MonthlyStatementsReportInteractorSpy: MonthlyStatementsReportInteractorProtocol {
    private(set) var reportDateCalled = false
    func reportDate() -> (month: Int, year: Int) {
        reportDateCalled = true
        return (month: 2, year: 2019)
    }

    private(set) var downloadReportCalled = false
    func downloadReport(callback _: @escaping Result<URL, NSError>.Callback) {
        downloadReportCalled = true
    }
}

class MonthlyStatementsReportInteractorFake: MonthlyStatementsReportInteractorSpy {
    var nextReportDateResult: (month: Int, year: Int)?
    override func reportDate() -> (month: Int, year: Int) {
        let value = super.reportDate()
        return nextReportDateResult ?? value
    }

    var nextDownloadReportResult: Result<URL, NSError>?
    override func downloadReport(callback: @escaping Result<URL, NSError>.Callback) {
        super.downloadReport(callback: callback)
        if let result = nextDownloadReportResult {
            callback(result)
        }
    }
}

class MonthlyStatementsReportPresenterSpy: MonthlyStatementsReportPresenterProtocol {
    let viewModel = MonthlyStatementsReportViewModel()
    var interactor: MonthlyStatementsReportInteractorProtocol?
    var router: MonthlyStatementsReportModuleProtocol?
    var analyticsManager: AnalyticsServiceProtocol?

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }
}
