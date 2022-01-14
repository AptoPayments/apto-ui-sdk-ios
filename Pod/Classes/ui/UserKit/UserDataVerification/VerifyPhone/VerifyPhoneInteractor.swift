//
//  VerifyPhoneInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import AptoSDK
import Foundation

protocol VerifyPhoneDataReceiver: AnyObject {
    func phoneNumberReceived(_ phone: PhoneNumber)
    func unknownPhoneNumber()
    func verificationReceived(_ verification: Verification)
    func sendPinSuccess()
    func sendPinError(_ error: NSError)
    func pinVerificationError(_ error: NSError)
    func pinVerificationSucceeded(_ verification: Verification)
    func pinVerificationWrongPin()
    func pinVerificationExpired()
}

class VerifyPhoneInteractor: VerifyPhoneInteractorProtocol {
    private unowned let dataReceiver: VerifyPhoneDataReceiver
    private let verificationType: VerificationParams<PhoneNumber, Verification>
    private let platform: AptoPlatformProtocol
    private var phone: PhoneNumber?
    private var verification: Verification?

    init(platform: AptoPlatformProtocol, verificationType: VerificationParams<PhoneNumber, Verification>,
         dataReceiver: VerifyPhoneDataReceiver)
    {
        self.platform = platform
        self.dataReceiver = dataReceiver
        self.verificationType = verificationType
    }

    func providePhoneNumber() {
        switch verificationType {
        case let .datapoint(phone):
            self.phone = phone
            dataReceiver.phoneNumberReceived(phone)
            sendPin()
        case let .verification(verification):
            self.verification = verification
            dataReceiver.unknownPhoneNumber()
            dataReceiver.sendPinSuccess()
        }
    }

    func sendPin() {
        guard let phone = phone else {
            return
        }
        platform.startPhoneVerification(phone) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.dataReceiver.sendPinError(error)
            case let .success(verification):
                self.verification = verification
                self.dataReceiver.verificationReceived(verification)
                self.dataReceiver.sendPinSuccess()
            }
        }
    }

    func resendPin() {
        guard let verification = verification else {
            return
        }
        platform.restartVerification(verification) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.dataReceiver.sendPinError(error)
            case let .success(verification):
                self.verification = verification
                self.dataReceiver.verificationReceived(verification)
                self.dataReceiver.sendPinSuccess()
            }
        }
    }

    func submitPin(_ pin: String) {
        guard let verification = verification else {
            return
        }
        verification.secret = pin
        platform.completeVerification(verification) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.dataReceiver.pinVerificationError(error)
            case let .success(verification):
                switch verification.status {
                case .pending:
                    self.dataReceiver.pinVerificationWrongPin()
                case .failed:
                    self.dataReceiver.pinVerificationExpired()
                case .passed:
                    verification.secret = pin
                    self.dataReceiver.pinVerificationSucceeded(verification)
                }
            }
        }
    }
}
