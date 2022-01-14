//
//  MonthlyStatementsReportPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import Bond
import XCTest

class MonthlyStatementsReportPresenterTest: XCTestCase {
    private var sut: MonthlyStatementsReportPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let router = MonthlyStatementsReportModuleSpy(serviceLocator: ServiceLocatorFake())
    private let interactor = MonthlyStatementsReportInteractorFake()
    private let analyticsManager = AnalyticsManagerSpy()

    override func setUp() {
        super.setUp()
        sut = MonthlyStatementsReportPresenter()
        sut.router = router
        sut.interactor = interactor
        sut.analyticsManager = analyticsManager
    }

    func testViewLoadedTrackAnalyticsEvent() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(analyticsManager.trackCalled)
        XCTAssertEqual(Event.monthlyStatementsReportStart, analyticsManager.lastEvent)
    }

    func testViewLoadedSetViewModelMonthAndYearToInteractorValues() {
        // Given
        interactor.nextReportDateResult = (month: 1, year: 2019)

        // When
        sut.viewLoaded()

        // Then
        XCTAssertEqual("January", sut.viewModel.month.value)
        XCTAssertEqual("2019", sut.viewModel.year.value)
    }

    func testViewLoadedCallDownload() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(interactor.downloadReportCalled)
    }

    func testDownloadReportShowLoadingView() {
        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(router.showLoadingViewCalled)
    }

    func testDownloadFailsUpdateViewModelErrorProperty() {
        // Given
        let error = BackendError(code: .other)
        interactor.nextDownloadReportResult = .failure(error)

        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(router.hideLoadingViewCalled)
        XCTAssertEqual(error, sut.viewModel.error.value)
        XCTAssertTrue(router.closeCalled)
    }

    func testDownloadSucceedUpdateViewModelUrlProperty() {
        // Given
        let url = ModelDataProvider.provider.url
        interactor.nextDownloadReportResult = .success(url)

        // When
        sut.viewLoaded()

        // Then
        XCTAssertTrue(router.hideLoadingViewCalled)
        XCTAssertEqual(url, sut.viewModel.url.value)
    }

    func testCloseTappedCallClose() {
        // When
        sut.closeTapped()

        // Then
        XCTAssertTrue(router.closeCalled)
    }
}
