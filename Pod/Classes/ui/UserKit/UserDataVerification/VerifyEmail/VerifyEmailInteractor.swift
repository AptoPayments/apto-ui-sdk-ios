//
//  VerifyEmailInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 02/10/2016.
//
//

import AptoSDK
import Foundation

protocol VerifyEmailDataReceiver: AnyObject {
    func emailReceived(_ email: Email)
    func unknownEmail()
    func verificationReceived(_ verification: Verification)
    func sendPinSuccess()
    func sendPinError(_ error: NSError)
    func pinVerificationSucceeded(_ verification: Verification)
    func pinVerificationFailed()
}

class VerifyEmailInteractor: VerifyEmailInteractorProtocol {
    unowned let dataReceiver: VerifyEmailDataReceiver
    let verificationType: VerificationParams<Email, Verification>
    let platform: AptoPlatformProtocol
    var email: Email?
    var verification: Verification?

    init(platform: AptoPlatformProtocol, verificationType: VerificationParams<Email, Verification>,
         dataReceiver: VerifyEmailDataReceiver)
    {
        self.platform = platform
        self.dataReceiver = dataReceiver
        self.verificationType = verificationType
    }

    func provideEmail() {
        switch verificationType {
        case let .datapoint(email):
            self.email = email
            dataReceiver.emailReceived(email)
            sendPin()
        case let .verification(verification):
            self.verification = verification
            dataReceiver.verificationReceived(verification)
        }
    }

    func sendPin() {
        guard let email = email else { return }
        platform.startEmailVerification(email) { [weak self] result in
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
        guard let verification = verification else { return }
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
        guard let verification = verification else { return }
        verification.secret = pin
        platform.completeVerification(verification) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.dataReceiver.pinVerificationFailed()
            case let .success(verification):
                if verification.status == .passed {
                    verification.secret = pin
                    self.dataReceiver.pinVerificationSucceeded(verification)
                } else {
                    self.dataReceiver.pinVerificationFailed()
                }
            }
        }
    }
}
