//
// TransactionListPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/01/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class TransactionListPresenterTest: XCTestCase {
  var sut: TransactionListPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = TransactionListModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = TransactionListInteractorFake()
  private let config = TransactionListModuleConfig(startDate: Date(),
                                                   endDate: Date(),
                                                   categoryId: MCCIcon.plane)
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()

    sut = TransactionListPresenter(config: config)
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedSetTitle() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertNotNil(sut.viewModel.title.value)
  }

  func testViewLoadedCallInteractor() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.fetchTransactionsCalled)
  }

  func testViewLoadedShowLoading() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.showLoadingSpinnerCalled)
  }

  func testFetchTransactionsFailsShowError() {
    // Given
    interactor.nextFetchTransactionsResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(router.hideLoadingSpinnerCalled)
    XCTAssertTrue(router.showErrorCalled)
  }

  func testFetchTransactionsSucceedUpdateViewModel() {
    // Given
    interactor.nextFetchTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(1, sut.viewModel.transactions.numberOfSections)
    XCTAssertEqual(1, sut.viewModel.transactions.numberOfItems(inSection: 0))
  }

  func testViewLoadedSuccessfullyReloadDataUpdateViewModel() {
    // Given
    interactor.nextFetchTransactionsResult = .success([dataProvider.transaction])
    sut.viewLoaded()

    // When
    sut.reloadData()

    // Then
    XCTAssertEqual(1, sut.viewModel.transactions.numberOfSections)
    XCTAssertEqual(1, sut.viewModel.transactions.numberOfItems(inSection: 0))
  }

  func testReloadDataDoNotShowSpinner() {
    // Given
    interactor.nextFetchTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.reloadData()

    // Then
    XCTAssertFalse(router.showLoadingSpinnerCalled)
  }

  func testViewLoadedSuccessfullyLoadMoreUpdateViewModel() {
    // Given
    interactor.nextFetchTransactionsResult = .success([dataProvider.transaction])
    sut.viewLoaded()

    // When
    sut.loadMoreTransactions { _ in }

    // Then
    XCTAssertEqual(1, sut.viewModel.transactions.numberOfSections)
    XCTAssertEqual(2, sut.viewModel.transactions.numberOfItems(inSection: 0))
  }

  func testLoadMoreTransactionsDoNotShowSpinner() {
    // Given
    interactor.nextFetchTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.loadMoreTransactions { _ in }

    // Then
    XCTAssertFalse(router.showLoadingSpinnerCalled)
  }

  func testCloseTappedCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }

  func testTransactionSelectedCallRouter() {
    // When
    sut.transactionSelected(dataProvider.transaction)

    // Then
    XCTAssertTrue(router.showTransactionDetailsCalled)
  }
  
  func testViewLoadedLogTransactionListEvent() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.transactionList)
  }
}
