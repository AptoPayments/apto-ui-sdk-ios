//
//  SelectBalanceStoreModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 05/07/2018.
//
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class SelectBalanceStoreModuleTest: XCTestCase {
  private var sut: SelectBalanceStoreModule! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let serviceLocator = ServiceLocatorFake()
  private lazy var platform = serviceLocator.platformFake
  private lazy var dataProvider = ModelDataProvider.provider
  private lazy var application = dataProvider.cardApplication
  private lazy var analyticsManager = serviceLocator.analyticsManagerSpy

  override func setUp() {
    super.setUp()

    sut = SelectBalanceStoreModule(serviceLocator: serviceLocator, application: application,
                                   analyticsManager: analyticsManager)
  }

  func testInitializeLoadContextConfiguration() {
    // When
    sut.initialize { _ in }

    // Then
    XCTAssertTrue(platform.fetchContextConfigurationCalled)
  }

  func testLoadContextConfigurationFailsCallFailureCompletion() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationFailure()
    var result: Result<UIViewController, NSError>?

    // When
    sut.initialize { returnResult in
      result = returnResult
    }

    // Then
    XCTAssertTrue(result!.isFailure) // swiftlint:disable:this force_unwrapping
    XCTAssertNotNil(result?.error)
  }

  func testContextConfigurationSucceedInitializeExternalOauthModule() {
    // Given
    serviceLocator.setUpSessionForContextConfigurationSuccess()
    let externalOauthModule = serviceLocator.moduleLocatorFake.externalOauthModuleFake

    // When
    sut.initialize { _ in }

    // Then
    XCTAssertTrue(externalOauthModule.initializeCalled)
  }

  func testExternalOauthSucceededNoDataToConfirmCallSetBalanceStore() {
    // Given
    let externalOauthModule = givenExternalOauthModulePresented()
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token", userData: nil))

    // When
    externalOauthModule.oauthSucceeded(custodian)

    // Then
    XCTAssertTrue(platform.setBalanceStoreCalled)
  }

  func testSetBalanceStoreSucceededCallOnFinish() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .valid, errorCode: nil))
    let externalOauthModule = givenExternalOauthModulePresented()
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token", userData: nil))

    // When
    externalOauthModule.oauthSucceeded(custodian)

    // Then
    XCTAssertTrue(onFinishCalled)
  }

  func testSetBalanceStoreValidationFailDoNotCallOnFinish() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: nil))
    let externalOauthModule = givenExternalOauthModulePresented()
    var onFinishCalled = false
    sut.onFinish = { _ in
      onFinishCalled = true
    }

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertFalse(onFinishCalled)
  }

  func testExternalOauthSucceededDataConfirmationRequiredDoNotCallSetBalanceStore() {
    // Given
    let externalOauthModule = givenExternalOauthModulePresented()
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token",
                                                           userData: dataProvider.emailDataPointList))

    // When
    externalOauthModule.oauthSucceeded(custodian)

    // Then
    XCTAssertFalse(platform.setBalanceStoreCalled)
  }

  func testExternalOauthSucceededDataConfirmationPresentDataConfirmation() {
    // Given
    let externalOauthModule = givenExternalOauthModulePresented()
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token",
                                                           userData: dataProvider.emailDataPointList))

    // When
    externalOauthModule.oauthSucceeded(custodian)

    // Then
    let dataConfirmationModule = serviceLocator.moduleLocatorFake.dataConfirmationModuleSpy
    XCTAssertTrue(dataConfirmationModule.initializeCalled)
    XCTAssertNotNil(dataConfirmationModule.onFinish)
    XCTAssertNotNil(dataConfirmationModule.onClose)
  }

  func testDataConfirmationPresentedOnFinishSaveOauthUserData() {
    // Given
    let externalOauthModule = givenExternalOauthModulePresented()
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token",
                                                           userData: dataProvider.emailDataPointList))
    externalOauthModule.oauthSucceeded(custodian)
    let dataConfirmationModule = serviceLocator.moduleLocatorFake.dataConfirmationModuleSpy

    // When
    dataConfirmationModule.finish(result: nil)

    // Then
    XCTAssertTrue(platform.saveOauthUserDataCalled)
  }

  func testDataConfirmationPresentedSaveOauthUserDataFailsUpdateUserData() {
    // Given
    let dataConfirmationModule = givenDataConfirmationPresented()
    platform.nextSaveOauthUserDataResult = .success(dataProvider.oauthSaveUserDataFailure)

    // When
    dataConfirmationModule.finish(result: nil)

    // Then
    XCTAssertFalse(platform.setBalanceStoreCalled)
    XCTAssertTrue(dataConfirmationModule.updateUserDataCalled)
  }

  func testDataConfirmationPresentedSaveOauthUserDataSucceedSetBalanceStore() {
    // Given
    let dataConfirmationModule = givenDataConfirmationPresented()
    platform.nextSaveOauthUserDataResult = .success(dataProvider.oauthSaveUserDataSucceed)

    // When
    dataConfirmationModule.finish(result: nil)

    // Then
    XCTAssertTrue(platform.setBalanceStoreCalled)
  }

  func testDataConfirmationPresentedUpdateUserFailsDoNotSetBalanceStore() {
    // Given
    let externalOauthModule = givenExternalOauthModulePresented()
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token", 
                                                           userData: dataProvider.emailDataPointList))
    externalOauthModule.oauthSucceeded(custodian)
    let dataConfirmationModule = serviceLocator.moduleLocatorFake.dataConfirmationModuleSpy
    platform.nextUpdateUserInfoResult = .failure(BackendError(code: .other))

    // When
    dataConfirmationModule.finish(result: nil)

    // Then
    XCTAssertFalse(platform.setBalanceStoreCalled)
  }

  func testDataConfirmationPresentOnCloseDoNotSetBalanceStore() {
    // Given
    let externalOauthModule = givenExternalOauthModulePresented()
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token",
                                                           userData: dataProvider.emailDataPointList))
    externalOauthModule.oauthSucceeded(custodian)
    let dataConfirmationModule = serviceLocator.moduleLocatorFake.dataConfirmationModuleSpy

    // When
    dataConfirmationModule.onClose?(dataConfirmationModule)

    // Then
    XCTAssertFalse(platform.setBalanceStoreCalled)
  }

  func testDataConfirmationPresentReloadUserDataCallSession() {
    // Given
    let dataConfirmationModule = givenDataConfirmationPresented()

    // When
    dataConfirmationModule.delegate?.reloadUserData{ _ in }

    // Then
    XCTAssertTrue(platform.fetchOAuthDataCalled)
  }

  func testReloadUserDataFailsCallbackFailure() {
    // Given
    var returnedResult: Result<DataPointList, NSError>?
    let dataConfirmationModule = givenDataConfirmationPresented()
    platform.nextFetchOAuthDataResult = .failure(BackendError(code: .other))

    // When
    dataConfirmationModule.delegate?.reloadUserData{ result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isFailure)
  }

  func testReloadUserDataSucceedCallbackSuccess() {
    // Given
    var returnedResult: Result<DataPointList, NSError>?
    let dataConfirmationModule = givenDataConfirmationPresented()
    platform.nextFetchOAuthDataResult = .success(dataProvider.oauthUserData)

    // When
    dataConfirmationModule.delegate?.reloadUserData{ result in
      returnedResult = result
    }

    // Then
    XCTAssertEqual(true, returnedResult?.isSuccess)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmCountryUnsupported() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90191))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmCountryUnsupported)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmRegionUnsupported() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90192))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmRegionUnsupported)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmAddressUnverified() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90193))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmAddressUnverified)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmCurrencyUnsupported() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90194))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmCurrencyUnsupported)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmCannotCaptureFunds() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90195))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmCannotCaptureFunds)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmInsufficientFunds() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90196))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmInsufficientFunds)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmBalanceNotFound() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90214))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmBalanceNotFound)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmAccessTokenInvalid() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90215))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmAccessTokenInvalid)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmScopesRequired() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90216))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmScopesRequired)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmLegalNameMissing() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90222))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmLegalNameMissing)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmDobMissing() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90223))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmDobMissing)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmDobInvalid() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90224))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmDobInvalid)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmAddressMissing() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90225))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmAddressMissing)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmEmailMissing() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90226))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmEmailMissing)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmEmailError() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 90227))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmEmailError)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmEmailSendsDisabled() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 200040))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmEmailSendsDisabled)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmInsufficientApplicationLimit() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 200041))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmInsufficientApplicationLimit)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreIdentityNotVerified() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 200046))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreIdentityNotVerified)
  }

  func testSetBalanceStoreValidationFailLogSelectBalanceStoreOauthConfirmUnknownError() {
    // Given
    platform.nextSetBalanceStoreResult = .success(SelectBalanceStoreResult(result: .invalid, errorCode: 0))
    let externalOauthModule = givenExternalOauthModulePresented()

    // When
    externalOauthModule.oauthSucceeded(dataProvider.custodian)

    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.selectBalanceStoreOauthConfirmUnknownError)
  }

  private func givenExternalOauthModulePresented() -> ExternalOAuthModuleFake {
    serviceLocator.setUpSessionForContextConfigurationSuccess()
    let externalOauthModule = serviceLocator.moduleLocatorFake.externalOauthModuleFake
    sut.initialize { _ in }

    return externalOauthModule
  }

  private func givenDataConfirmationPresented() -> DataConfirmationModuleSpy {
    let externalOauthModule = givenExternalOauthModulePresented()
    let custodian = dataProvider.custodian
    custodian.externalCredentials = .oauth(OauthCredential(oauthTokenId: "token",
                                                           userData: dataProvider.emailDataPointList))
    externalOauthModule.oauthSucceeded(custodian)

    return serviceLocator.moduleLocatorFake.dataConfirmationModuleSpy
  }
}
