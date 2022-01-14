//
// UserStorageTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/08/2019.
//

@testable import AptoSDK
import Foundation

class UserStorageSpy: UserStorageProtocol {
    private(set) var createUserCalled = false
    private(set) var lastCreateUserApiKey: String?
    private(set) var lastCreateUserUserData: DataPointList?
    private(set) var lastCreateUserCustodianUid: String?
    private(set) var lastCreateUserMetadata: String?
    func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?, metadata: String?,
                    callback _: @escaping Result<AptoUser, NSError>.Callback)
    {
        createUserCalled = true
        lastCreateUserApiKey = apiKey
        lastCreateUserUserData = userData
        lastCreateUserCustodianUid = custodianUid
        lastCreateUserMetadata = metadata
    }

    func loginWith(_: String, verifications _: [Verification],
                   callback _: @escaping Result<AptoUser, NSError>.Callback) {}

    func getUserData(_: String, userToken _: String, filterInvalidTokenResult _: Bool,
                     callback _: @escaping Result<AptoUser, NSError>.Callback) {}

    func updateUserData(_: String, userToken _: String, userData _: DataPointList,
                        callback _: @escaping Result<AptoUser, NSError>.Callback) {}

    private(set) var startPrimaryVerificationCalled = false
    private(set) var lastStarPrimaryVerificationApiKey: String?
    private(set) var lastStarPrimaryVerificationUserToken: String?
    func startPrimaryVerification(_: String, userToken: String, callback _: @escaping Result<Verification, NSError>.Callback) {
        startPrimaryVerificationCalled = true
        lastStarPrimaryVerificationUserToken = userToken
    }

    func startPhoneVerification(_: String, phone _: PhoneNumber,
                                callback _: @escaping Result<Verification, NSError>.Callback) {}

    func startEmailVerification(_: String, email _: Email,
                                callback _: @escaping Result<Verification, NSError>.Callback) {}

    func startBirthDateVerification(_: String, birthDate _: BirthDate,
                                    callback _: @escaping Result<Verification, NSError>.Callback) {}

    func startDocumentVerification(_: String, userToken _: String, documentImages _: [UIImage], selfie _: UIImage?,
                                   livenessData _: [String: AnyObject]?, associatedTo _: WorkflowObject?,
                                   callback _: @escaping Result<Verification, NSError>.Callback) {}

    func documentVerificationStatus(_: String, verificationId _: String,
                                    callback _: @escaping Result<Verification, NSError>.Callback) {}

    func completeVerification(_: String, verificationId _: String, secret _: String?,
                              callback _: @escaping Result<Verification, NSError>.Callback) {}

    func verificationStatus(_: String, verificationId _: String,
                            callback _: @escaping Result<Verification, NSError>.Callback) {}

    func restartVerification(_: String, verificationId _: String,
                             callback _: @escaping Result<Verification, NSError>.Callback) {}

    func saveOauthData(_: String, userToken _: String, userData _: DataPointList, custodian _: Custodian,
                       callback _: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback) {}

    func fetchOauthData(_: String, custodian _: Custodian,
                        callback _: @escaping Result<OAuthUserData, NSError>.Callback) {}

    private(set) var fetchStatementsPeriodCalled = false
    private(set) var lastFetchStatementsPeriodApiKey: String?
    private(set) var lastFetchStatementsPeriodUserToken: String?
    func fetchStatementsPeriod(_ apiKey: String, userToken: String,
                               callback _: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback)
    {
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
                        callback _: @escaping Result<MonthlyStatementReport, NSError>.Callback)
    {
        fetchStatementCalled = true
        lastFetchStatementApiKey = apiKey
        lastFetchStatementUserToken = userToken
        lastFetchStatementMonth = month
        lastFetchStatementYear = year
    }
}

class UserStorageFake: UserStorageSpy {
    var nextCreateUserResult: Result<AptoUser, NSError>?
    override func createUser(_ apiKey: String, userData: DataPointList, custodianUid: String?, metadata: String?,
                             callback: @escaping Result<AptoUser, NSError>.Callback)
    {
        super.createUser(apiKey, userData: userData, custodianUid: custodianUid, metadata: metadata, callback: callback)
        if let result = nextCreateUserResult {
            callback(result)
        }
    }

    var nextFetchStatementsPeriodResult: Result<MonthlyStatementsPeriod, NSError>?
    override func fetchStatementsPeriod(_ apiKey: String, userToken: String,
                                        callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback)
    {
        super.fetchStatementsPeriod(apiKey, userToken: userToken, callback: callback)
        if let result = nextFetchStatementsPeriodResult {
            callback(result)
        }
    }

    var nextFetchStatementResult: Result<MonthlyStatementReport, NSError>?
    override func fetchStatement(_ apiKey: String, userToken: String, month: Int, year: Int,
                                 callback: @escaping Result<MonthlyStatementReport, NSError>.Callback)
    {
        super.fetchStatement(apiKey, userToken: userToken, month: month, year: year,
                             callback: callback)
        if let result = nextFetchStatementResult {
            callback(result)
        }
    }
}
