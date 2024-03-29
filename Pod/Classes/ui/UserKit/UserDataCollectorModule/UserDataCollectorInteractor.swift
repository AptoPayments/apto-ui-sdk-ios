//
//  DataCollectorInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 01/02/16.
//
//

import AptoSDK
import Bond
import Foundation

protocol UserDataCollectorDataReceiver: AnyObject {
    func setDataCollectorError(_ error: NSError)
    func showNextStep()
    func showLoadingView()
    func hideLoadingView()
    func set(_ userData: DataPointList,
             missingData: RequiredDataPointList,
             requiredData: RequiredDataPointList,
             skipSteps: Bool,
             mode: UserDataCollectorFinalStepMode,
             primaryCredentialType: DataPointType,
             secondaryCredentialType: DataPointType,
             googleGeocodingAPIKey: String?)
    func show(error: NSError)
    func userReady(_ user: AptoUser)
}

class UserDataCollectorInteractor: UserDataCollectorInteractorProtocol {
    private let platform: AptoPlatformProtocol
    private let initialUserData: DataPointList
    private let internalUserData: DataPointList
    private unowned let dataReceiver: UserDataCollectorDataReceiver
    private let config: UserDataCollectorConfig
    private var verifyingSecondaryCredential = false

    init(platform: AptoPlatformProtocol, initialUserData: DataPointList, config: UserDataCollectorConfig,
         dataReceiver: UserDataCollectorDataReceiver)
    {
        self.platform = platform
        self.initialUserData = initialUserData
        internalUserData = initialUserData.copy() as! DataPointList // swiftlint:disable:this force_cast
        self.dataReceiver = dataReceiver
        self.config = config
    }

    func provideDataCollectorData() {
        // Remove primary credential from the list of user required datapoints
        let requiredData = config.userRequiredData.copy() as! RequiredDataPointList // swiftlint:disable:this force_cast
        requiredData.removeDataPointsOf(type: config.primaryAuthCredential)
        let missingData = requiredData.getMissingDataPoints(internalUserData)

        dataReceiver.set(internalUserData,
                         missingData: missingData,
                         requiredData: requiredData,
                         skipSteps: config.skipSteps,
                         mode: config.mode,
                         primaryCredentialType: config.primaryAuthCredential,
                         secondaryCredentialType: config.secondaryAuthCredential,
                         googleGeocodingAPIKey: config.googleGeocodingAPIKey)
    }

    // User data collection

    func allUserDataCollected(_ userData: DataPointList, callback: @escaping Result<AptoUser, NSError>.Callback) {
        if shouldCreateUserAccount() {
            dataReceiver.showLoadingView()
            createUser(userData) { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.dataReceiver.show(error: error)
                case let .success(newUser):
                    callback(.success(newUser))
                }
                self?.dataReceiver.hideLoadingView()
            }
        } else {
            let differences = initialUserData.modifiedDataPoints(compareWith: userData)
            if !differences.dataPoints.isEmpty {
                dataReceiver.showLoadingView()
                updateUser(differences) { [weak self] result in
                    switch result {
                    case let .failure(error):
                        self?.dataReceiver.show(error: error)
                    case let .success(updatedUser):
                        callback(.success(updatedUser))
                    }
                    self?.dataReceiver.hideLoadingView()
                }
            } else {
                getCurrentUser(callback)
            }
        }
    }
}

// Navigation Handling

extension UserDataCollectorInteractor {
    func nextStepTapped(fromStep _: DataCollectorStep) {
        dataReceiver.showNextStep()
    }
}

// User creation, account recovery, update user and get user data

private extension UserDataCollectorInteractor {
    func shouldCreateUserAccount() -> Bool {
        if platform.currentToken() != nil {
            return false
        }
        if let primaryCredentialDatapoint = internalUserData.getDataPointsOf(type: config.primaryAuthCredential)?.first,
           let primaryCredentialDatapointVerification = primaryCredentialDatapoint.verification
        {
            guard let secondaryCredential = internalUserData.getDataPointsOf(type: config.secondaryAuthCredential)?.first,
                  secondaryCredential.complete()
            else {
                return false
            }
            return primaryCredentialDatapointVerification.status == .passed
        } else {
            return false
        }
    }

    func createUser(_ userData: DataPointList, callback: @escaping Result<AptoUser, NSError>.Callback) {
        platform.createUser(userData: userData.filterNonCompletedDataPoints()) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(user):
                callback(.success(user))
            }
        }
    }

    func updateUser(_ userData: DataPointList, callback: @escaping Result<AptoUser, NSError>.Callback) {
        platform.updateUserInfo(userData.filterNonCompletedDataPoints()) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(user):
                callback(.success(user))
            }
        }
    }

    func getCurrentUser(_ callback: @escaping Result<AptoUser, NSError>.Callback) {
        platform.fetchCurrentUserInfo(callback: callback)
    }
}
