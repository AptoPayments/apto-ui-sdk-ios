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
  private let token = "token"
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

  // MARK: - Fetch monthly spending
  func testSutNotInitializedFetchMonthlySpendingCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlySpending, NSError>?

    // When
    sut.fetchMonthlySpending(cardId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testNoCurrentUserFetchMonthlySpendingCallbackFailure() {
    // Given
    givenSutInitialized()
    var returnedResult: Result<MonthlySpending, NSError>?

    // When
    sut.fetchMonthlySpending(cardId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testFetchMonthlySpendingCallStorage() {
    // Given
    givenCurrentUser()

    // When
    sut.fetchMonthlySpending(cardId: "card_id", month: 2, year: 2019) { _ in }

    // Then
    let storage = storageLocator.financialAccountsStorageFake
    XCTAssertTrue(storage.fetchMonthlySpendingCalled)
    XCTAssertEqual(apiKey, storage.lastFetchMonthlySpendingApiKey)
    XCTAssertEqual(token, storage.lastFetchMonthlySpendingUserToken)
    XCTAssertEqual("card_id", storage.lastFetchMonthlySpendingAccountId)
    XCTAssertEqual(2, storage.lastFetchMonthlySpendingMonth)
    XCTAssertEqual(2019, storage.lastFetchMonthlySpendingYear)
  }

  func testFetchMonthlySpendingFailCallbackFailure() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<MonthlySpending, NSError>?
    storageLocator.financialAccountsStorageFake.nextFetchMonthlySpendingResult = .failure(BackendError(code: .other))

    // When
    sut.fetchMonthlySpending(cardId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testFetchMonthlySpendingSucceedCallbackSuccess() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<MonthlySpending, NSError>?
    let storage = storageLocator.financialAccountsStorageFake
    storage.nextFetchMonthlySpendingResult = .success(dataProvider.monthlySpending(date: Date()))

    // When
    sut.fetchMonthlySpending(cardId: "card_id", month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  // MARK: - Fetch monthly statement report
  func testSutNotInitializedFetchMonthlyStatementsPeriodCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlyStatementsPeriod, NSError>?

    // When
    sut.fetchMonthlyStatementsPeriod { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testNoCurrentUserFetchMonthlyStatementsPeriodCallbackFailure() {
    // Given
    givenSutInitialized()
    var returnedResult: Result<MonthlyStatementsPeriod, NSError>?

    // When
    sut.fetchMonthlyStatementsPeriod { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testFetchMonthlyStatementsPeriodCallStorage() {
    // Given
    givenCurrentUser()

    // When
    sut.fetchMonthlyStatementsPeriod { _ in }

    // Then
    let storage = storageLocator.userStorageFake
    XCTAssertTrue(storage.fetchStatementsPeriodCalled)
    XCTAssertEqual(apiKey, storage.lastFetchStatementsPeriodApiKey)
    XCTAssertEqual(token, storage.lastFetchStatementsPeriodUserToken)
  }

  func testFetchMonthlyStatementsPeriodFailCallbackFailure() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<MonthlyStatementsPeriod, NSError>?
    storageLocator.userStorageFake.nextFetchStatementsPeriodResult = .failure(BackendError(code: .other))

    // When
    sut.fetchMonthlyStatementsPeriod { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testFetchMonthlyStatementsPeriodSucceedCallbackSuccess() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<MonthlyStatementsPeriod, NSError>?
    storageLocator.userStorageFake.nextFetchStatementsPeriodResult = .success(dataProvider.monthlyStatementsPeriod)

    // When
    sut.fetchMonthlyStatementsPeriod { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  // MARK: - Fetch monthly statement report
  func testSutNotInitializedFetchMonthlyStatementReportCallbackFailure() {
    // Given
    var returnedResult: Result<MonthlyStatementReport, NSError>?

    // When
    sut.fetchMonthlyStatementReport(month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testNoCurrentUserFetchMonthlyStatementReportCallbackFailure() {
    // Given
    givenSutInitialized()
    var returnedResult: Result<MonthlyStatementReport, NSError>?

    // When
    sut.fetchMonthlyStatementReport(month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
    guard let returnedError = returnedResult?.error as? BackendError else {
      return XCTFail("Wrong error type returned")
    }
    XCTAssertEqual(BackendError.ErrorCodes.invalidSession.rawValue, returnedError.code)
  }

  func testFetchMonthlyStatementReportCallStorage() {
    // Given
    givenCurrentUser()

    // When
    sut.fetchMonthlyStatementReport(month: 2, year: 2019) { _ in }

    // Then
    let storage = storageLocator.userStorageFake
    XCTAssertTrue(storage.fetchStatementCalled)
    XCTAssertEqual(apiKey, storage.lastFetchStatementApiKey)
    XCTAssertEqual(token, storage.lastFetchStatementUserToken)
    XCTAssertEqual(2, storage.lastFetchStatementMonth)
    XCTAssertEqual(2019, storage.lastFetchStatementYear)
  }

  func testFetchMonthlyStatementReportFailCallbackFailure() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<MonthlyStatementReport, NSError>?
    storageLocator.userStorageFake.nextFetchStatementResult = .failure(BackendError(code: .other))

    // When
    sut.fetchMonthlyStatementReport(month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testFetchMonthlyStatementReportSucceedCallbackSuccess() {
    // Given
    givenCurrentUser()
    var returnedResult: Result<MonthlyStatementReport, NSError>?
    storageLocator.userStorageFake.nextFetchStatementResult = .success(dataProvider.monthlyStatementReport)

    // When
    sut.fetchMonthlyStatementReport(month: 2, year: 2019) { result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
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
    XCTAssertNotNil(storage.lastIssueCardAdditionalFields)
    XCTAssertNotNil(storage.lastIssueCardInitialFundingSourceId)
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

  func testIssueCardSucceedCallbackSuccess() {
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

  // MARK: - Is biometric enabled
  func testIsBiometricEnabledReturnsStorageValue() {
    let storage = storageLocator.userPreferencesStorageFake
    let storageValues = [true, false]

    for value in storageValues {
      // Given
      storage.shouldUseBiometric = value

      // When
      let isEnabled = sut.isBiometricEnabled()

      // Then
      XCTAssertEqual(value, isEnabled)
    }
  }

  func testSetIsBiometricEnabledUpdatesStorageValue() {
    let storage = storageLocator.userPreferencesStorageFake
    let storageValues = [true, false]

    for value in storageValues {
      sut.setIsBiometricEnabled(value)

      // Then
      XCTAssertEqual(value, storage.shouldUseBiometric)
    }
  }

  // MARK: - Helper methods
  private func givenSutInitialized() {
    sut.initializeWithApiKey(apiKey)
  }

  private func givenCurrentUser() {
    if !sut.initialized { givenSutInitialized() }
    storageLocator.userTokenStorageFake.setCurrent(token: token, withPrimaryCredential: .email,
                                                   andSecondaryCredential: .phoneNumber)
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
