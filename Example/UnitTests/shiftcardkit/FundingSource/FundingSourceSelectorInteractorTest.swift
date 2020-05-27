import XCTest
@testable import AptoSDK
@testable import AptoUISDK

final class FundingSourceSelectorInteractorTest: XCTestCase {
  private var sut: FundingSourceSelectorInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let platform = AptoPlatformFake()
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()
    sut = FundingSourceSelectorInteractor(card: dataProvider.card, platform: platform)
  }

  func test_should_forward_loading_funding_sources_to_platform() {
    // When
    sut.loadFundingSources(forceRefresh: true) { _ in
      // Then
      XCTAssertTrue(self.platform.fetchCardFundingSourcesCalled)
    }
  }
  
  func test_should_forward_active_card_funding_source_to_platform() {
    // When
    sut.activeCardFundingSource(forceRefresh: true) { _ in
      // Then
      XCTAssertTrue(self.platform.activateCardCalled)
    }
  }
  
  func test_should_forward_set_active_funding_source_to_platform() {
    // When
    sut.setActive(fundingSource: dataProvider.fundingSource) { _ in
      // Then
      XCTAssertTrue(self.platform.setCardFundingSourceCalled)
    }
  }
}
