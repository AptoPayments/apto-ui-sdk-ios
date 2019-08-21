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
  func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?,
                  callback: @escaping Result<ShiftUser, NSError>.Callback) {
    createUserCalled = true
    lastCreateUserApiKey = apiKey
    lastCreateUserUserData = userData
    lastCreateUserCustodianUid = custodianUid
  }

  func loginWith(_ apiKey: String, verifications: [Verification],
                 callback: @escaping Result<ShiftUser, NSError>.Callback) {
  }

  func getUserData(_ apiKey: String, userToken: String, availableHousingTypes: [HousingType],
                   availableIncomeTypes: [IncomeType], availableSalaryFrequencies: [SalaryFrequency],
                   filterInvalidTokenResult: Bool, callback: @escaping Result<ShiftUser, NSError>.Callback) {
  }

  func updateUserData(_ apiKey: String, userToken: String, userData: DataPointList,
                      callback: @escaping Result<ShiftUser, NSError>.Callback) {
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
}

class UserStorageFake: UserStorageSpy {
  var nextCreateUserResult: Result<ShiftUser, NSError>?
  override func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?,
                           callback: @escaping Result<ShiftUser, NSError>.Callback) {
    super.createUser(apiKey, userData: userData, custodianUid: custodianUid, callback: callback)
    if let result = nextCreateUserResult {
      callback(result)
    }
  }
}
