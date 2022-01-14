//
//  AuthInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/12/2017.
//

import AptoSDK

class AuthInteractor: AuthInteractorProtocol {
    private let platform: AptoPlatformProtocol
    private unowned let dataReceiver: AuthDataReceiver
    private let config: AuthModuleConfig
    var internalUserData: DataPointList
    private var initializationData: InitializationData?

    // MARK: - Initialization

    init(platform: AptoPlatformProtocol, initialUserData: DataPointList, config: AuthModuleConfig,
         dataReceiver: AuthDataReceiver, initializationData: InitializationData?)
    {
        self.platform = platform
        internalUserData = initialUserData.copy() as! DataPointList // swiftlint:disable:this force_cast
        self.dataReceiver = dataReceiver
        self.config = config
        self.initializationData = initializationData
    }

    // MARK: - AuthInteractorProtocol protocol

    func provideAuthData() {
        dataReceiver.set(internalUserData,
                         primaryCredentialType: config.primaryAuthCredential,
                         secondaryCredentialType: config.secondaryAuthCredential)
    }

    func nextTapped() {
        switch config.primaryAuthCredential {
        case .phoneNumber:
            guard let phoneDataPoint = internalUserData.getDataPointsOf(type: .phoneNumber)?.first as? PhoneNumber else {
                dataReceiver.show(error: ServiceError(code: .internalIncosistencyError, reason: "Phone not available"))
                return
            }
            dataReceiver.showPhoneVerification(verificationType: .datapoint(phoneDataPoint))
        case .email:
            guard let emailDataPoint = internalUserData.getDataPointsOf(type: .email)?.first as? Email else {
                dataReceiver.show(error: ServiceError(code: .internalIncosistencyError, reason: "Email not available"))
                return
            }
            dataReceiver.showEmailVerification(verificationType: .datapoint(emailDataPoint))
        case .birthDate:
            guard let birthdateDataPoint = internalUserData.getDataPointsOf(type: .birthDate)?.first as? BirthDate else {
                dataReceiver.show(error: ServiceError(code: .internalIncosistencyError, reason: "Birthdate not available"))
                return
            }
            dataReceiver.showBirthdateVerification(verificationType: .datapoint(birthdateDataPoint))
        default:
            dataReceiver.show(error: ServiceError(code: .internalIncosistencyError,
                                                  reason: "Primary Credential Type not Supported."))
        }
    }

    func phoneVerificationSucceeded(_ verification: Verification) {
        internalUserData.phoneDataPoint.verification = verification
        if config.secondaryAuthCredential == .phoneNumber {
            // This is the verification of the secondary credentials. Recover user
            recoverUser()
        } else {
            // Phone is the primary credential. See if there's a secondary credential that can be verified to recover an
            // existent user
            launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: verification)
        }
    }

    func phoneVerificationFailed() {
        internalUserData.phoneDataPoint.verification?.status = .failed
    }

    func emailVerificationSucceeded(_ verification: Verification) {
        internalUserData.emailDataPoint.verification = verification
        if config.secondaryAuthCredential == .email {
            // This is the verification of the secondary credentials. Recover user
            recoverUser()
        } else {
            // Email is the primary credential. See if there's a secondary credential that can be verified to recover an
            // existent user
            launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: verification)
        }
    }

    func emailVerificationFailed() {
        internalUserData.emailDataPoint.verification?.status = .failed
    }

    func birthdateVerificationSucceeded(_ verification: Verification) {
        internalUserData.birthDateDataPoint.verification = verification
        if config.secondaryAuthCredential == .birthDate {
            // This is the verification of the secondary credentials. Recover user
            recoverUser()
        } else {
            // Birthdate is the primary credential. See if there's a secondary credential that can be verified to recover an
            // existent user
            launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: verification)
        }
    }

    func birthdateVerificationFailed() {
        internalUserData.birthDateDataPoint.verification?.status = .failed
    }

    fileprivate func launchSecondaryCredentialVerificationOrReturn(primaryCredentialVerification: Verification) {
        if let secondaryCredential = primaryCredentialVerification.secondaryCredential {
            // Existing User. Verify secondary credential
            switch secondaryCredential.verificationType {
            case .email:
                dataReceiver.showEmailVerification(verificationType: .verification(secondaryCredential))
            case .birthDate:
                dataReceiver.showBirthdateVerification(verificationType: .verification(secondaryCredential))
            case .phoneNumber:
                dataReceiver.showPhoneVerification(verificationType: .verification(secondaryCredential))
            default:
                break
            }
        } else {
            // New user.
            guard internalUserData.getDataPointsOf(type: config.primaryAuthCredential)?.first != nil else {
                dataReceiver.show(error: ServiceError(code: .internalIncosistencyError,
                                                      reason: "Primary Credential not Available"))
                return
            }
            dataReceiver.showLoadingView()
            platform.createUser(userData: internalUserData,
                                custodianUid: initializationData?.custodianId,
                                metadata: initializationData?.userMetadata) { [weak self] result in
                self?.dataReceiver.hideLoadingView()
                switch result {
                case let .failure(error):
                    self?.dataReceiver.show(error: error)
                case let .success(user):
                    self?.dataReceiver.returnExistingUser(user)
                }
            }
        }
    }

    fileprivate func recoverUser() {
        guard let primaryCredentialDatapoint = internalUserData.getDataPointsOf(type: config.primaryAuthCredential)?.first,
              let secondaryCredentialDatapoint = internalUserData.getDataPointsOf(type: config.secondaryAuthCredential)?.first,
              let primaryCredentialDatapointVerification = primaryCredentialDatapoint.verification,
              let secondaryCredentialDatapointVerification = secondaryCredentialDatapoint.verification
        else {
            dataReceiver.show(error: ServiceError(code: .internalIncosistencyError,
                                                  reason: "Can't obtain login verifications"))
            return
        }
        dataReceiver.showLoadingView()
        platform.loginUserWith(verifications: [primaryCredentialDatapointVerification,
                                               secondaryCredentialDatapointVerification]) { [weak self] result in
            self?.dataReceiver.hideLoadingView()
            switch result {
            case let .failure(error):
                self?.dataReceiver.show(error: error)
            case let .success(user):
                self?.dataReceiver.returnExistingUser(user)
            }
        }
    }
}
