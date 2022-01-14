//
// CardMonthlyStatsInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/01/2019.
//

import AptoSDK
@testable import AptoUISDK
import XCTest

class CardMonthlyStatsInteractorTest: XCTestCase {
    var sut: CardMonthlyStatsInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let card = ModelDataProvider.provider.card
    private lazy var platform = ServiceLocatorFake().platformFake
    private let dataProvider = ModelDataProvider.provider

    override func setUp() {
        super.setUp()

        sut = CardMonthlyStatsInteractor(card: card, platform: platform)
    }

    func testFetchMonthlySpendingCallCardSession() {
        // When
        sut.fetchMonthlySpending(date: Date()) { _ in }

        // Then
        XCTAssertTrue(platform.fetchMonthlySpendingCalled)
    }

    func testFetchMonthlySpendingUseAppropriateDate() {
        // Given
        let components = DateComponents(year: 2019, month: 1, day: 8)
        let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping

        // When
        sut.fetchMonthlySpending(date: date) { _ in }

        // Then
        XCTAssertEqual(1, platform.lastFetchMonthlySpendingMonth)
        XCTAssertEqual(2019, platform.lastFetchMonthlySpendingYear)
    }

    func testFetchingSpendingFailsCallbackFailure() {
        // Given
        var returnedResult: Result<MonthlySpending, NSError>?
        platform.nextFetchMonthlySpendingResult = .failure(BackendError(code: .other))

        // When
        sut.fetchMonthlySpending(date: Date()) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testFetchingSpendingSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<MonthlySpending, NSError>?
        platform.nextFetchMonthlySpendingResult = .success(dataProvider.monthlySpending(date: Date()))

        // When
        sut.fetchMonthlySpending(date: Date()) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testFetchingSpendingSucceedSetDate() {
        // Given
        var returnedResult: Result<MonthlySpending, NSError>?
        let components = DateComponents(year: 2019, month: 1, day: 8)
        let date = Calendar.current.date(from: components)! // swiftlint:disable:this force_unwrapping
        platform.nextFetchMonthlySpendingResult = .success(dataProvider.monthlySpending(date: date))

        // When
        sut.fetchMonthlySpending(date: date) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(date, returnedResult?.value?.date)
    }

    func testIsStatementFeatureEnabledCallPlatform() {
        // When
        sut.isStatementsFeatureEnabled { _ in }

        // Then
        XCTAssertTrue(platform.isFeatureEnabledCalled)
        XCTAssertEqual(FeatureKey.showMonthlyStatementsOption.rawValue, platform.lastIsFeatureEnabledKey?.rawValue)
    }

    func testStatementsFeatureEnabledCallbackTrue() {
        // Given
        platform.setCardOptions(CardOptions(features: [.showMonthlyStatementsOption: true]))

        // When
        sut.isStatementsFeatureEnabled { isEnabled in
            // Then
            XCTAssertTrue(isEnabled)
        }
    }

    func testStatementsFeatureDisabledCallbackFalse() {
        // Given
        platform.setCardOptions(CardOptions(features: [.showMonthlyStatementsOption: false]))

        // When
        sut.isStatementsFeatureEnabled { isEnabled in
            // Then
            XCTAssertFalse(isEnabled)
        }
    }

    func testFetchStatementPeriodCallPlatform() {
        // When
        sut.fetchStatementsPeriod { _ in }

        // Then
        XCTAssertTrue(platform.fetchMonthlyStatementsPeriodCalled)
    }

    func testFetchStatementSucceedCallbackSuccess() {
        // Given
        platform.nextFetchMonthlyStatementsPeriodResult = .success(dataProvider.monthlyStatementsPeriod)

        // When
        sut.fetchStatementsPeriod { [unowned self] result in
            // Then
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(self.dataProvider.monthlyStatementsPeriod, result.value)
        }

        func testFetchStatementFailsCallbackFailure() {
            // Given
            let error = BackendError(code: .other)
            platform.nextFetchMonthlyStatementsPeriodResult = .failure(error)

            // When
            sut.fetchStatementsPeriod { result in
                // Then
                XCTAssertTrue(result.isFailure)
                XCTAssertEqual(error, result.error)
            }
        }
    }
}
