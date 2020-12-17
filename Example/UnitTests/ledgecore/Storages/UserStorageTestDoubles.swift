//
// UserStorageTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/08/2019.
//

import Foundation
@testable import AptoSDK

class UserStorageSpy: UserStorageProtocol {
  private(set) var createUserCalled = false
  private(set) var lastCreateUserApiKey: String?
  private(set) var lastCreateUserUserData: DataPointList?
  private(set) var lastCreateUserCustodianUid: String?
  private(set) var lastCreateUserMetadata: String?
  func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?, metadata: String?,
                  callback: @escaping Result<ShiftUser, NSError>.Callback) {
    createUserCalled = true
    lastCreateUserApiKey = apiKey
    lastCreateUserUserData = userData
    lastCreateUserCustodianUid = custodianUid
    lastCreateUserMetadata = metadata
  }

  func loginWith(_ apiKey: String, verifications: [Verification],
                 callback: @escaping Result<ShiftUser, NSError>.Callback) {
  }

  func getUserData(_ apiKey: String, userToken: String, filterInvalidTokenResult: Bool,
                   callback: @escaping Result<ShiftUser, NSError>.Callback) {
  }

  func updateUserData(_ apiKey: String, userToken: String, userData: DataPointList,
                      callback: @escaping Result<ShiftUser, NSError>.Callback) {
  }

  private(set) var startPrimaryVerificationCalled = false
  private(set) var lastStarPrimaryVerificationApiKey: String?
  private(set) var lastStarPrimaryVerificationUserToken: String?
  func startPrimaryVerification(_ apiKey: String, userToken: String, callback: @escaping Result<Verification, NSError>.Callback) {
    startPrimaryVerificationCalled = true
    lastStarPrimaryVerificationUserToken = userToken
  }

  func startPhoneVerification(_ apiKey: String, phone: PhoneNumber,
                              callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func startEmailVerification(_ apiKey: String, email: Email,
                              callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func startBirthDateVerification(_ apiKey: String, birthDate: BirthDate,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func startDocumentVerification(_ apiKey: String, userToken: String, documentImages: [UIImage], selfie: UIImage?,
                                 livenessData: [String: AnyObject]?, associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func documentVerificationStatus(_ apiKey: String, verificationId: String,
                                  callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func completeVerification(_ apiKey: String, verificationId: String, secret: String?,
                            callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func verificationStatus(_ apiKey: String, verificationId: String,
                          callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func restartVerification(_ apiKey: String, verificationId: String,
                           callback: @escaping Result<Verification, NSError>.Callback) {
  }

  func saveOauthData(_ apiKey: String, userToken: String, userData: DataPointList, custodian: Custodian,
                     callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback) {
  }

  func fetchOauthData(_ apiKey: String, custodian: Custodian,
                      callback: @escaping Result<OAuthUserData, NSError>.Callback) {
  }

  private(set) var fetchStatementsPeriodCalled = false
  private(set) var lastFetchStatementsPeriodApiKey: String?
  private(set) var lastFetchStatementsPeriodUserToken: String?
  func fetchStatementsPeriod(_ apiKey: String, userToken: String,
                             callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
    fetchStatementsPeriodCalled = true
    lastFetchStatementsPeriodApiKey = apiKey
    lastFetchStatementsPeriodUserToken = userToken
  }

  private(set) var fetchStatementCalled = false
  private(set) var lastFetchStatementApiKey: String?
  private(set) var lastFetchStatementUserToken: String?
  private(set) var lastFetchStatementMonth: Int?
  private(set) var lastFetchStatementYear: Int?
  func fetchStatement(_ apiKey: String, userToken: String, month: Int, year: Int,
                      callback: @escaping Result<MonthlyStatementReport, NSError>.Callback) {
    fetchStatementCalled = true
    lastFetchStatementApiKey = apiKey
    lastFetchStatementUserToken = userToken
    lastFetchStatementMonth = month
    lastFetchStatementYear = year
  }
}

class UserStorageFake: UserStorageSpy {
  var nextCreateUserResult: Result<ShiftUser, NSError>?
  override func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?, metadata: String?,
                           callback: @escaping Result<ShiftUser, NSError>.Callback) {
    super.createUser(apiKey, userData: userData, custodianUid: custodianUid, metadata: metadata, callback: callback)
    if let result = nextCreateUserResult {
      callback(result)
    }
  }

  var nextFetchStatementsPeriodResult: Result<MonthlyStatementsPeriod, NSError>?
  override func fetchStatementsPeriod(_ apiKey: String, userToken: String,
                                      callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
    super.fetchStatementsPeriod(apiKey, userToken: userToken, callback: callback)
    if let result = nextFetchStatementsPeriodResult {
      callback(result)
    }
  }

  var nextFetchStatementResult: Result<MonthlyStatementReport, NSError>?
  override func fetchStatement(_ apiKey: String, userToken: String, month: Int, year: Int,
                               callback: @escaping Result<MonthlyStatementReport, NSError>.Callback) {
    super.fetchStatement(apiKey, userToken: userToken, month: month, year: year,
                         callback: callback)
    if let result = nextFetchStatementResult {
      callback(result)
    }
  }
}
