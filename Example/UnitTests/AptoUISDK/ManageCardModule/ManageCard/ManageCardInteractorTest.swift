//
// ManageCardInteractorTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class ManageCardInteractorTest: XCTestCase {
    var sut: ManageCardInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private lazy var platform = ServiceLocatorFake().platformFake
    private let card = ModelDataProvider.provider.card
    private let dataProvider = ModelDataProvider.provider

    override func setUp() {
        super.setUp()

        sut = ManageCardInteractor(platform: platform, card: card)
    }

    func testProvideFundingSourceCallSession() {
        // When
        sut.provideFundingSource(forceRefresh: true) { _ in }

        // Then
        XCTAssertTrue(platform.fetchCardFundingSourceCalled)
        XCTAssertEqual(true, platform.lastFetchCardFundingSourceForceRefresh)
    }

    func testProvideFundingSourceWithoutForceRefreshCallSessionWithoutForceRefresh() {
        // When
        sut.provideFundingSource(forceRefresh: false) { _ in }

        // Then
        XCTAssertEqual(false, platform.lastFetchCardFundingSourceForceRefresh)
    }

    func testGetFundingSourceFailsCallbackError() {
        // Given
        var returnedResult: Result<Card, NSError>?
        platform.nextFetchCardFundingSourceResult = .failure(BackendError(code: .other))

        // When
        sut.provideFundingSource(forceRefresh: true) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testGetFundingSourceSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<Card, NSError>?
        platform.nextFetchCardFundingSourceResult = .success(dataProvider.fundingSource)

        // When
        sut.provideFundingSource(forceRefresh: true) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testGetFundingSourceSucceedSetCardFundingSource() {
        // Given
        let fundingSource = dataProvider.fundingSource
        platform.nextFetchCardFundingSourceResult = .success(fundingSource)

        // When
        sut.provideFundingSource(forceRefresh: true) { _ in }

        // Then
        XCTAssertEqual(fundingSource, card.fundingSource)
    }

    func testReloadCardCallSessionRetrievingBalance() {
        // When
        sut.reloadCard { _ in }

        // Then
        XCTAssertTrue(platform.fetchCardCalled)
        XCTAssertEqual(true, platform.lastFetchCardRetrieveBalances)
    }

    func testReloadCardGetFinancialAccountFailsCallbackError() {
        // Given
        platform.nextFetchCardResult = .failure(BackendError(code: .other))
        var returnedResult: Result<Card, NSError>?

        // When
        sut.reloadCard { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testReloadCardGetFinancialAccountSucceedCallbackSuccess() {
        // Given
        platform.nextFetchCardResult = .success(dataProvider.card)
        var returnedResult: Result<Card, NSError>?

        // When
        sut.reloadCard { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testActivateCardCallCardSession() {
        // When
        sut.activateCard { _ in }

        // Then
        XCTAssertTrue(platform.activateCardCalled)
    }

    func testCardActivationFailsCallbackError() {
        // Given
        var returnedResult: Result<Card, NSError>?
        platform.nextActivateCardResult = .failure(BackendError(code: .other))

        // When
        sut.activateCard { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testCardActivationSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<Card, NSError>?
        platform.nextActivateCardResult = .success(dataProvider.card)

        // When
        sut.activateCard { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testIsShowDetailedCardActivityEnabledCallSession() {
        // Given
        platform.nextIsShowDetailedCardActivityEnabledResult = true

        // When
        let isEnabled = sut.isShowDetailedCardActivityEnabled()

        // Then
        XCTAssertTrue(platform.isShowDetailedCardActivityEnabledCalled)
        XCTAssertTrue(isEnabled)
    }

    func testProvideTransactionsCallCardSession() {
        // Given
        let filters = TransactionListFilters(rows: 20, lastTransactionId: nil)

        // When
        sut.provideTransactions(filters: filters, forceRefresh: true) { _ in }

        // Then
        XCTAssertTrue(platform.fetchCardTransactionsCalled)
    }

    func testRetrieveTransactionsFailsCallbackFailure() {
        // Given
        var returnedResult: Result<[Transaction], NSError>?
        platform.nextFetchCardTransactionsResult = .failure(BackendError(code: .other))
        let filters = TransactionListFilters(rows: 20, lastTransactionId: nil)

        // When
        sut.provideTransactions(filters: filters, forceRefresh: true) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testRetrieveTransactionsSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<[Transaction], NSError>?
        platform.nextFetchCardTransactionsResult = .success([dataProvider.transaction])
        let filters = TransactionListFilters(rows: 20, lastTransactionId: nil)

        // When
        sut.provideTransactions(filters: filters, forceRefresh: true) { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testActivatePhysicalCardCallCardSession() {
        // When
        sut.activatePhysicalCard(code: "111111") { _ in }

        // Then
        XCTAssertTrue(platform.activatePhysicalCardCalled)
    }

    func testPhysicalActivationCallFailsCallbackFailure() {
        // Given
        var returnedResult: Result<Void, NSError>?
        platform.nextActivatePhysicalCardResult = .failure(BackendError(code: .other))

        // When
        sut.activatePhysicalCard(code: "111111") { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testPhysicalActivationOperationFailsCallbackFailure() {
        // Given
        var returnedResult: Result<Void, NSError>?
        let activationResult = PhysicalCardActivationResult(type: .error, errorCode: 90211, errorMessage: nil)
        platform.nextActivatePhysicalCardResult = .success(activationResult)

        // When
        sut.activatePhysicalCard(code: "111111") { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testPhysicalActivationOperationSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<Void, NSError>?
        let activationResult = PhysicalCardActivationResult(type: .activated, errorCode: nil, errorMessage: nil)
        platform.nextActivatePhysicalCardResult = .success(activationResult)

        // When
        sut.activatePhysicalCard(code: "111111") { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }

    func testLoadFundingSourceCallCardSession() {
        // When
        sut.loadFundingSources { _ in }

        // Then
        XCTAssertTrue(platform.fetchCardFundingSourcesCalled)
        XCTAssertEqual(true, platform.lastFetchCardFundingSourcesForceRefresh)
    }

    func testCardFundingSourcesFailsCallbackFailure() {
        // Given
        var returnedResult: Result<[FundingSource], NSError>?
        platform.nextFetchCardFundingSourcesResult = .failure(BackendError(code: .other))

        // When
        sut.loadFundingSources { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isFailure)
    }

    func testCardFundingSourcesSucceedCallbackSuccess() {
        // Given
        var returnedResult: Result<[FundingSource], NSError>?
        platform.nextFetchCardFundingSourcesResult = .success([dataProvider.fundingSource])

        // When
        sut.loadFundingSources { result in
            returnedResult = result
        }

        // Then
        XCTAssertEqual(true, returnedResult?.isSuccess)
    }
}
