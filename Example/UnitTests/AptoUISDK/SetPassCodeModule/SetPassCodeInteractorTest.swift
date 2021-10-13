import XCTest
import AptoSDK
@testable import AptoUISDK

class SetPassCodeInteractorTest: XCTestCase {
  private var sut: SetPassCodeInteractor! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var platform = serviceLocator.platformFake
  private let card = ModelDataProvider.provider.card
  private let verification = ModelDataProvider.provider.verification
  private let passCode = "0876"

  override func setUp() {
    super.setUp()
    sut = SetPassCodeInteractor(platform: platform, card: card, verification: verification)
  }

  func testChangeCodeCallCardSessionToSetPassCode() {
    // When
    sut.changeCode(passCode) { _ in }

    // Then
    XCTAssertTrue(platform.setCardPassCodeCalled)
    XCTAssertEqual(card.accountId, platform.lastSetCardPassCodeCardId)
    XCTAssertEqual(passCode, platform.lastSetCardPassCodePassCode)
  }

  func testChangeCodeSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<Card, NSError>?
    platform.nextSetCardPassCodeResult = .success(Void())

    // When
    sut.changeCode(passCode) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testChangeCodeFailsCallbackFailure() {
    // Given
    var returnedResult: Result<Card, NSError>?
    platform.nextSetCardPassCodeResult = .failure(BackendError(code: .other))

    // When
    sut.changeCode(passCode) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }
}
