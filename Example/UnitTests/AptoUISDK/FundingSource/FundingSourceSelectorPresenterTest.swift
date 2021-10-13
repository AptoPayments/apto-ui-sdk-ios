import XCTest
@testable import AptoSDK
@testable import AptoUISDK
import Bond

final class FundingSourceSelectorPresenterTest: XCTestCase {
  private var sut: FundingSourceSelectorPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let router = FundingSourceSelectorModuleSpy(serviceLocator: ServiceLocatorFake())
  private let interactor = FundingSourceSelectorInteractorSpy()
  private let analyticsManager = AnalyticsManagerSpy()
  private let dataProvider = ModelDataProvider.provider
  
  override func setUp() {
    super.setUp()
    let config = FundingSourceSelectorPresenterConfig(hideFundingSourcesReconnectButton: true)
    sut = FundingSourceSelectorPresenter(config: config)
    sut.router = router
    sut.interactor = interactor
    sut.analyticsManager = analyticsManager
  }

  func test_should_fire_analytic_event() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(Event.manageCardFundingSourceSelector, analyticsManager.lastEvent)
  }
  
  func test_should_hide_fundingSources_reconnect_button() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertTrue(sut.viewModel.hideReconnectButton.value)
  }
  
  func test_should_refresh_data_without_forcing_refresh_when_initializing() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertFalse(interactor.loadFundingSourcesForceRefresh)
  }
 
  func test_should_refresh_data_forcing_refresh_when_refres_data_tapped() {
    // When
    sut.refreshDataTapped()
    
    // Then
    XCTAssertTrue(interactor.loadFundingSourcesForceRefresh)
  }
  
  func test_should_show_loading_spinner_when_refreshing_data() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertTrue(sut.viewModel.showLoadingSpinner.value)
  }

  func test_should_do_nothing_when_no_active_funding_source_is_active() {
    // Given
    givenThereAreValidFundingSourcesAvailable()
    activateFundingSourceAt(index: 0)
    
    // When
    sut.fundingSourceSelected(index: 0)
    
    // Then
    XCTAssertFalse(interactor.setActiveCalled)
  }
   
  func test_should_set_funding_source_as_active_when_selection_changed() {
    // Given
    givenThereAreValidFundingSourcesAvailable(3)
    activateFundingSourceAt(index: 3)
    
    // When
    sut.fundingSourceSelected(index: 0)
    
    // Then
    XCTAssertTrue(interactor.setActiveCalled)
  }
  
  func test_should_show_loading_when_funding_source_selection_changed() {
    // Given
    givenThereAreValidFundingSourcesAvailable(3)
    activateFundingSourceAt(index: 3)
    
    // When
    sut.fundingSourceSelected(index: 0)
    
    // Then
    XCTAssertTrue(sut.viewModel.showLoadingSpinner.value)
  }
  
  func test_should_hide_loading_when_funding_source_selection_changed_finished_successfully() {
    // Given
    givenThereAreValidFundingSourcesAvailable(3)
    activateFundingSourceAt(index: 3)
    interactor.nextSetActiveResult = .success(dataProvider.fundingSource)
    
    // When
    sut.fundingSourceSelected(index: 0)
    
    // Then
    XCTAssertFalse(sut.viewModel.showLoadingSpinner.value)
  }
  
  func test_should_hide_loading_when_funding_source_selection_changed_finished_with_error() {
    // Given
    givenThereAreValidFundingSourcesAvailable(3)
    activateFundingSourceAt(index: 3)
    interactor.nextSetActiveResult = .failure(.init())
    
    // When
    sut.fundingSourceSelected(index: 0)
    
    // Then
    XCTAssertFalse(sut.viewModel.showLoadingSpinner.value)
  }
  
  func test_should_show_error_when_funding_source_selection_changed_finished_with_error() {
    // Given
    givenThereAreValidFundingSourcesAvailable(3)
    activateFundingSourceAt(index: 3)
    interactor.nextSetActiveResult = .failure(.init())
    
    // When
    sut.fundingSourceSelected(index: 0)
    
    // Then
    XCTAssertTrue(router.lastMessageShownIsError!)
    XCTAssertTrue(router.closeCalled)
  }
  
  func test_should_change_funding_source_when_selection_changed_successfully() {
    // Given
    givenThereAreValidFundingSourcesAvailable(3)
    activateFundingSourceAt(index: 3)
    interactor.nextSetActiveResult = .success(dataProvider.fundingSource)
    
    // When
    sut.fundingSourceSelected(index: 0)
    
    // Then
    XCTAssertTrue(router.fundingSourceChangedCalled)
  }
  
  func test_should_add_funding_source() {
    // When
    sut.addFundingSourceTapped()
    
    // Then
    XCTAssertTrue(router.addFundingSourceCalled)
  }
 
  func test_should_close_when_tapped() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeCalled)
  }
}

// MARK: - Helpers

extension FundingSourceSelectorPresenterTest {
  fileprivate func givenThereAreValidFundingSourcesAvailable(_ number: Int = 3) {
    let fundingSources = (0...number).map { _ in dataProvider.fundingSource }
    sut.viewModel.fundingSources.send(fundingSources)
  }
  
  fileprivate func activateFundingSourceAt(index: Int) {
    sut.viewModel.activeFundingSourceIdx.send(index)
  }
}
