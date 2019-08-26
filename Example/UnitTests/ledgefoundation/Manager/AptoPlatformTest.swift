//
// AptoPlatformTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 11/07/2019.
//

import XCTest
@testable import AptoSDK

class AptoPlatformTest: XCTestCase {
  private var sut = AptoPlatform.defaultManager()

  // Collaborators
  private let serviceLocator = CoreServiceLocatorFake()
  private lazy var storageLocator = serviceLocator.storageLocatorFake
  private let delegate = AptoPlatformDelegateSpy()
  private let apiKey = "api_key"
  private let environment = AptoPlatformEnvironment.production
  private let setupCertPinning = true
  private let dataProvider = ModelDataProvider.provider

  override func setUp() {
    super.setUp()
    sut = AptoPlatform(serviceLocator: serviceLocator)
    sut.delegate = delegate
  }

  // MARK: - Initialize
  func testInitializeWithApiKeyEnvironmentSetupCertPinningInitializeSDK() {
    // When
    sut.initializeWithApiKey(apiKey, environment: environment, setupCertPinning: setupCertPinning)

    // Then
    XCTAssertEqual(apiKey, sut.apiKey)
    XCTAssertEqual(environment, sut.environment)
    XCTAssertTrue(sut.initialized)
  }

  func testInitializeWithApiKeySetEnvironmentToSandbox() {
    // When
    givenSutInitialized()

    // Then
    XCTAssertEqual(AptoPlatformEnvironment.production, sut.environment)
  }

  func testInitializeNotifyDelegate() {
    // When
    givenSutInitialized()

    // Then
    XCTAssertTrue(delegate.sdkInitializedCalled)
    XCTAssertEqual(apiKey, delegate.lastApiKeyReceived)
  }

  // MARK: - CreateUser
  func testCreateUserCallStorage() {
    // Given
    givenSutInitialized()
    let storage = storageLocator.userStorageFake

    // When
    sut.createUser(userData: dataProvider.emailDataPointList) { _ in }

    // Then
    XCTAssertTrue(storage.createUserCalled)
  }

  func testCreateUserFailsCallbackFailure() {
    // Given
    givenSutInitialized()
    let storage = storageLocator.userStorageFake
    storage.nextCreateUserResult = .failure(BackendError(code: .emailInvalid))
    var returnedResult: Result<ShiftUser, NSError>?

    // When
    sut.createUser(userData: dataProvider.emailDataPointList) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testCreateUserSucceedLoadContextConfiguration() {
    // Given
    givenSutInitialized()
    let storage = storageLocator.userStorageFake
    storage.nextCreateUserResult = .success(dataProvider.user)

    // When
    sut.createUser(userData: dataProvider.emailDataPointList) { _ in }

    // Then
    let configurationStorage = storageLocator.configurationStorageFake
    XCTAssertTrue(configurationStorage.contextConfigurationCalled)
  }

  func testCreateUserAndLoadContextConfigurationSucceedCallbackSuccess() {
    // Given
    givenSutInitialized()
    let storage = storageLocator.userStorageFake
    storage.nextCreateUserResult = .success(dataProvider.user)
    let configurationStorage = storageLocator.configurationStorageFake
    configurationStorage.nextContextConfigurationResult = .success(dataProvider.contextConfiguration)
    var returnedResult: Result<ShiftUser, NSError>?

    // When
    sut.createUser(userData: dataProvider.emailDataPointList) { result in
      returnedResult = result
    }

    // Then
    let analyticsManager = serviceLocator.analyticsManagerSpy
    let userTokenStorage = storageLocator.userTokenStorageFake
    XCTAssertEqual(true, returnedResult?.isSuccess)
    XCTAssertTrue(analyticsManager.createUserCalled)
    XCTAssertEqual(dataProvider.user.userId, analyticsManager.lastCreateUserUserId)
    XCTAssertTrue(userTokenStorage.setCurrentTokenCalled)
    XCTAssertTrue(delegate.newUserTokenReceivedCalled)
  }

  func testCreateUserSucceedLoadContextConfigurationFailsCallbackFailure() {
    // Given
    givenSutInitialized()
    let storage = storageLocator.userStorageFake
    storage.nextCreateUserResult = .success(dataProvider.user)
    let configurationStorage = storageLocator.configurationStorageFake
    configurationStorage.nextContextConfigurationResult = .failure(BackendError(code: .other))
    var returnedResult: Result<ShiftUser, NSError>?

    // When
    sut.createUser(userData: dataProvider.emailDataPointList) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  // MARK: - Issue card
  func testSutNotInitializedIssueCardCallbackFailure() {
    // Given
    var returnedResult: Result<Card, NSError>?

    // When
    sut.issueCard(cardProduct: dataProvider.cardProduct, custodian: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testNoCurrentUserIssueCardCallbackFailure() {
    // Given
    givenSutInitialized()
    var returnedResult: Result<Card, NSError>?

    // When
    sut.issueCard(cardProduct: dataProvider.cardProduct, custodian: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testIssueCardCallStorage() {
    // Given
    givenCurrentUser()

    // When
    sut.issueCard(cardProduct: dataProvider.cardProduct, custodian: dataProvider.custodian,
                  additionalFields: [:], initialFundingSourceId: "initial_funding_source_id") { _ in }

    // Then
    let storage = storageLocator.financialAccountsStorageFake
    XCTAssertTrue(storage.issueCardCalled)
    XCTAssertNotNil(storage.lastIssueCardApiKey)
    XCTAssertNotNil(storage.lastIssueCardUserToken)
    XCTAssertNotNil(storage.lastIssueCardCardProduct)
    XCTAssertNotNil(storage.lastIssueCardCustodian)
    XCTAssertEqual(BalanceVersion.v1, storage.lastIssueCardBalanceVersion)
    XCTAssertNotNil(storage.lastIssueCardAdditionalFields)
    XCTAssertNotNil(storage.lastIssueCardInitialFundingSourceId)
  }

  func testBalanceV2EnabledIssueCardUseBalanceV2() {
    // Given
    givenCurrentUser()
    givenBalanceV2Enabled()

    // When
    sut.issueCard(cardProduct: dataProvider.cardProduct, custodian: nil) { _ in }

    // Then
    let storage = storageLocator.financialAccountsStorageFake
    XCTAssertEqual(BalanceVersion.v2, storage.lastIssueCardBalanceVersion)
  }

  func testIssueCardFailCallbackFailure() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<Card, NSError>?
    storageLocator.financialAccountsStorageFake.nextIssueCardResult = .failure(BackendError(code: .other))

    // When
    sut.issueCard(cardProduct: dataProvider.cardProduct, custodian: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testIssueCardSucceedCallbackSuccees() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<Card, NSError>?
    storageLocator.financialAccountsStorageFake.nextIssueCardResult = .success(dataProvider.card)

    // When
    sut.issueCard(cardProduct: dataProvider.cardProduct, custodian: nil) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  // MARK: - Set User Token
  func testSetUserTokenSaveTokenInStorageWithDefaultCredentials() {
    // Given
    let storage = storageLocator.userTokenStorageFake
    let userToken = "user_token"

    // When
    sut.setUserToken(userToken)

    // Then
    XCTAssertTrue(storage.setCurrentTokenCalled)
    XCTAssertEqual(userToken, storage.lastSetCurrentToken)
    XCTAssertEqual(DataPointType.phoneNumber, storage.lastSetCurrentTokenPrimaryCredential)
    XCTAssertEqual(DataPointType.email, storage.lastSetCurrentTokenSecondaryCredential)
  }

  func testSetUserTokenWithPreviousCredentialsReuseCredentials() {
    // Given
    let storage = storageLocator.userTokenStorageFake
    let userToken = "user_token"
    let primaryCredential = DataPointType.address
    let secondaryCredential = DataPointType.birthDate
    storage.setCurrent(token: "", withPrimaryCredential: primaryCredential, andSecondaryCredential: secondaryCredential)

    // When
    sut.setUserToken(userToken)

    // Then
    XCTAssertEqual(userToken, storage.lastSetCurrentToken)
    XCTAssertEqual(primaryCredential, storage.lastSetCurrentTokenPrimaryCredential)
    XCTAssertEqual(secondaryCredential, storage.lastSetCurrentTokenSecondaryCredential)
  }

  // MARK: - Helper methods
  private func givenSutInitialized() {
    sut.initializeWithApiKey(apiKey)
  }

  private func givenCurrentUser() {
    if !sut.initialized { givenSutInitialized() }
    storageLocator.userTokenStorageFake.setCurrent(token: "token", withPrimaryCredential: .email,
                                                   andSecondaryCredential: .phoneNumber)
  }

  private func givenBalanceV2Enabled() {
    storageLocator.featuresStorageSpy.update(features: [FeatureKey.useBalanceVersionV2: true])
  }
}

private class AptoPlatformDelegateSpy: AptoPlatformDelegate {
  private(set) var newUserTokenReceivedCalled = false
  private(set) var lastUserTokenReceived: String?
  func newUserTokenReceived(_ userToken: String?) {
    newUserTokenReceivedCalled = true
    lastUserTokenReceived = userToken
  }

  private(set) var sdkInitializedCalled = false
  private(set) var lastApiKeyReceived: String?
  func sdkInitialized(apiKey: String) {
    sdkInitializedCalled = true
    lastApiKeyReceived = apiKey
  }

  private(set) var sdkDeprecatedCalled = false
  func sdkDeprecated() {
    sdkDeprecatedCalled = true
  }
}
