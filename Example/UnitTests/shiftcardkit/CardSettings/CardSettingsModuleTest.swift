//
//  CardSettingsModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 03/10/2019.
//

import XCTest
import AptoSDK
@testable import AptoUISDK

class CardSettingsModuleTest: XCTestCase {
  private var sut: CardSettingsModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private let card = ModelDataProvider.provider.card
  private let phoneCaller = PhoneCallerSpy()
  private lazy var platform = serviceLocator.platformFake
  private let dataProvider = ModelDataProvider.provider
  private let delegate = CardSettingsModuleDelegateSpy()

  override func setUp() {
    super.setUp()
    sut = CardSettingsModule(serviceLocator: serviceLocator, card: card, phoneCaller: phoneCaller)
    sut.delegate = delegate
  }

  func testCardWithoutCardProductIdInitializeCallbackFailure() {
    // Given
    sut = CardSettingsModule(serviceLocator: serviceLocator, card: dataProvider.cardWithoutCardProductId,
                             phoneCaller: phoneCaller)

    // When
    sut.initialize { result in
      // Then
      XCTAssertTrue(result.isFailure)
      XCTAssertTrue(result.error is ServiceError)
      // swiftlint:disable force_unwrapping
      // swiftlint:disable force_cast
      XCTAssertEqual(ServiceError.ErrorCodes.internalIncosistencyError.rawValue,
                     (result.error! as! ServiceError).code)
      // swiftlint:enable force_unwrapping
      // swiftlint:enable force_cast
    }
  }

  func testInitializeFetchContextConfiguration() {
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertTrue(platform.fetchContextConfigurationCalled)
  }

  func testFetchContextConfigurationFailCallbackFailure() {
    // Given
    platform.nextFetchContextConfigurationResult = .failure(BackendError(code: .other))

    // When
    sut.initialize { result in
      // Then
      XCTAssertTrue(result.isFailure)
      XCTAssertTrue(result.error is BackendError)
    }
  }

  func testFetchContextConfigurationSucceedFetchCardProduct() {
    // Given
    givenFetchContextConfigurationSucceed()

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertTrue(platform.fetchCardProductCalled)
    XCTAssertEqual(card.cardProductId, platform.lastFetchCardProductCardProductId)
    XCTAssertEqual(false, platform.lastFetchCardProductForceRefresh)
  }

  func testFetchCardProductFailCallbackFailure() {
    // Given
    givenFetchContextConfigurationSucceed()
    platform.nextFetchCardProductResult = .failure(BackendError(code: .other))

    // When
    sut.initialize { result in
      // Then
      XCTAssertTrue(result.isFailure)
      XCTAssertTrue(result.error is BackendError)
    }
  }

  func testFetchCardProductSucceedConfigurePresenter() {
    // Given
    givenFetchCardProductSucceed()
    let presenter = serviceLocator.presenterLocatorFake.cardSettingsPresenterSpy

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertNotNil(presenter.router)
    XCTAssertNotNil(presenter.interactor)
    XCTAssertNotNil(presenter.view)
    XCTAssertNotNil(presenter.analyticsManager)
  }

  func testFetchCardProductSucceedCallbackSuccess() {
    // Given
    givenFetchCardProductSucceed()

    // When
    sut.initialize { result in
      // Then
      XCTAssertTrue(result.isSuccess)
    }
  }

  func testCloseFromCardSettingsCallClose() {
    // Given
    var closeCalled = false
    sut.onClose = { _ in
      closeCalled = true
    }

    // When
    sut.closeFromShiftCardSettings()

    // Then
    XCTAssertTrue(closeCalled)
  }

  func testChangeCardPinShowSetPinModule() {
    // Given
    let setPinModule = serviceLocator.moduleLocatorFake.setPinModuleSpy

    // When
    sut.changeCardPin()

    // Then
    XCTAssertTrue(setPinModule.initializeCalled)
  }

  func testShowVoIPShowVoIPModule() {
    // Given
    let voIPModule = serviceLocator.moduleLocatorFake.voIPModuleSpy

    // When
    sut.showVoIP(actionSource: .customerSupport)

    // Then
    XCTAssertTrue(voIPModule.initializeCalled)
  }

  func testCallUrlUseCaller() {
    // Given
    let url = dataProvider.url

    // When
    sut.call(url: url) {}

    // Then
    XCTAssertTrue(phoneCaller.callCalled)
  }

  func testShowCardInfoNotifyDelegate() {
    // When
    sut.showCardInfo()

    // Then
    XCTAssertTrue(delegate.showCardInfoCalled)
  }

  func testHideCardInfoNotifyDelegate() {
    // When
    sut.hideCardInfo()

    // Then
    XCTAssertTrue(delegate.hideCardInfoCalled)
  }

  func testCardStateChangedNotifyDelegate() {
    // When
    sut.cardStateChanged(includingTransactions: true)

    // Then
    XCTAssertTrue(delegate.cardStateChangedCalled)
    XCTAssertEqual(true, delegate.lastCardStateChangedIncludingTransactions)
  }

  func testShowContentShowContentPresenterModule() {
    // Given
    let contentPresenterModule = serviceLocator.moduleLocatorFake.contentPresenterModuleSpy

    // When
    sut.show(content: .plainText("Content"), title: "Title")

    // Then
    XCTAssertTrue(contentPresenterModule.initializeCalled)
  }

  func testShowMonthlyStatementsShowMonthlyStatementsListModule() {
    // Given
    let monthlyStatementsListModule = serviceLocator.moduleLocatorFake.monthlyStatementsListModuleSpy

    // When
    sut.showMonthlyStatements()

    // Then
    XCTAssertTrue(monthlyStatementsListModule.initializeCalled)
  }

  func testAuthenticateCallAuthenticationManager() {
    // Given
    let authenticationManager = serviceLocator.systemServicesLocatorFake.authenticationManagerFake

    // When
    sut.authenticate { _ in }

    // Then
    XCTAssertTrue(authenticationManager.authenticateCalled)
  }

  func testAuthenticationSucceedCallbackAccessGranted() {
    // Given
    let authenticationManager = serviceLocator.systemServicesLocatorFake.authenticationManagerFake
    authenticationManager.nextAuthenticateResult = true

    // When
    sut.authenticate { result in
      // Then
      XCTAssertTrue(result)
    }
  }

  func testAuthenticationFailsCallbackAccessDenied() {
    // Given
    let authenticationManager = serviceLocator.systemServicesLocatorFake.authenticationManagerFake
    authenticationManager.nextAuthenticateResult = false

    // When
    sut.authenticate { result in
      // Then
      XCTAssertFalse(result)
    }
  }

  // MARK: - Helper methods
  private func givenFetchContextConfigurationSucceed() {
    platform.nextFetchContextConfigurationResult = .success(dataProvider.contextConfiguration)
  }

  private func givenFetchCardProductSucceed() {
    givenFetchContextConfigurationSucceed()
    platform.nextFetchCardProductResult = .success(dataProvider.cardProduct)
  }
}
