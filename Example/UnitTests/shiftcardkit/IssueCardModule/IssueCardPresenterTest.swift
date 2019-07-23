//
//  IssueCardPresenterTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class IssueCardPresenterTest: XCTestCase {
  private var sut: IssueCardPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var router = serviceLocator.moduleLocatorFake.issueCardModuleSpy
  private lazy var interactor = serviceLocator.interactorLocatorFake.issueCardInteractorFake
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()

  override func setUp() {
    super.setUp()

    sut = IssueCardPresenter(router: router, interactor: interactor, configuration: nil)
    sut.analyticsManager = analyticsManager
  }

  func testViewLoadedCallInteractorToIssueCardSetViewModelToLoadingState() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.issueCardCalled)
    XCTAssertEqual(IssueCardViewState.loading, sut.viewModel.state.value)
  }

  func testIssueCardFailureSetViewModelToErrorState() {
    // Given
    interactor.nextIssueCardResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(IssueCardViewState.error(error: BackendError(code: .other)), sut.viewModel.state.value)
  }

  func testIssueCardSucceedCallCardIssued() {
    // Given
    interactor.nextIssueCardResult = .success(ModelDataProvider.provider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(IssueCardViewState.done, sut.viewModel.state.value)
    XCTAssertTrue(router.cardIssuedCalled)
  }

  func testRequestCardTappedCallInteractorToIssueCardSetViewModelToLoadingState() {
    // When
    sut.requestCardTapped()

    // Then
    XCTAssertTrue(interactor.issueCardCalled)
    XCTAssertEqual(IssueCardViewState.loading, sut.viewModel.state.value)
  }

  func testRequestCardTappedIssueCardFailureSetViewModelToErrorState() {
    // Given
    interactor.nextIssueCardResult = .failure(BackendError(code: .other))

    // When
    sut.requestCardTapped()

    // Then
    XCTAssertEqual(IssueCardViewState.error(error: BackendError(code: .other)), sut.viewModel.state.value)
  }

  func testRequestCardTappedIssueCardSucceedCallCardIssued() {
    // Given
    interactor.nextIssueCardResult = .success(ModelDataProvider.provider.card)

    // When
    sut.requestCardTapped()

    // Then
    XCTAssertEqual(IssueCardViewState.done, sut.viewModel.state.value)
    XCTAssertTrue(router.cardIssuedCalled)
  }

  func testRetryTappedCallInteractorToIssueCardSetViewModelToLoadingState() {
    // When
    sut.retryTapped()

    // Then
    XCTAssertTrue(interactor.issueCardCalled)
    XCTAssertEqual(IssueCardViewState.loading, sut.viewModel.state.value)
  }

  func testInitWithActionConfigurationViewLoadedSetViewModelStateToShowLegalNotice() {
    // Given
    let configuration = IssueCardActionConfiguration(legalNotice: .plainText("Legal Notice"), errorAsset: nil)
    sut = IssueCardPresenter(router: router, interactor: interactor, configuration: configuration)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertEqual(IssueCardViewState.showLegalNotice(content: configuration.legalNotice!), sut.viewModel.state.value)
  }

  func testBackTappedCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeTappedCalled)
  }

  func testShowURLCallRouter() {
    // Given
    let url = TappedURL(title: nil, url: ModelDataProvider.provider.url)

    // When
    sut.show(url: url)

    // Then
    XCTAssertTrue(router.showURLCalled)
  }
  
  func testViewLoadedLogIssueCardEvent() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.issueCard)
  }
  
  func testTrackErrorLogIssueCardErrorBalanceInsufficientFundsEvent() {
    // Given
    interactor.nextIssueCardResult = .failure(BackendError(code: .balanceInsufficientFunds))
    
    // When
    sut.requestCardTapped()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.issueCardInsufficientFunds)
  }
  
  func testTrackErrorLogIssueCardErrorBalanceValidationsEmailSendsDisabledEvent() {
    // Given
    interactor.nextIssueCardResult = .failure(BackendError(code: .balanceValidationsEmailSendsDisabled))
    
    // When
    sut.requestCardTapped()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.issueCardEmailSendsDisabled)
  }
  
  func testTrackErrorLogIssueCardErrorBalanceValidationsInsufficientApplicationLimit() {
    // Given
    interactor.nextIssueCardResult = .failure(BackendError(code: .balanceValidationsInsufficientApplicationLimit))
    
    // When
    sut.requestCardTapped()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.issueCardInsufficientApplicationLimit)
  }
  
  func testTrackErrorLogIssueCardErrorUnknownError() {
    // Given
    interactor.nextIssueCardResult = .failure(BackendError(code: .undefinedError))
    
    // When
    sut.requestCardTapped()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.issueCardUnknownError)
  }
}
