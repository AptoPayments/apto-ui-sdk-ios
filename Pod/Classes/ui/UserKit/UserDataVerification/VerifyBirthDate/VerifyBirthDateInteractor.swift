//
//  VerifyBirthDateInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import AptoSDK
import Foundation

class VerifyBirthDateInteractor: VerifyBirthDateInteractorProtocol {
    private unowned let dataReceiver: VerifyBirthDateDataReceiver
    private let verificationType: VerificationParams<BirthDate, Verification>
    private let platform: AptoPlatformProtocol
    private var verification: Verification?
    private var birthDate: BirthDate?

    init(platform: AptoPlatformProtocol, verificationType: VerificationParams<BirthDate, Verification>,
         dataReceiver: VerifyBirthDateDataReceiver)
    {
        self.platform = platform
        self.dataReceiver = dataReceiver
        self.verificationType = verificationType
    }

    func provideBirthDate() {
        switch verificationType {
        case let .datapoint(birthDate):
            self.birthDate = birthDate
            startVerification()
        case let .verification(verification):
            self.verification = verification
            dataReceiver.verificationReceived(verification)
        }
    }

    func startVerification() {
        guard let birthDate = birthDate, birthDate.date.value != nil else {
            return
        }
        platform.startBirthDateVerification(birthDate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.dataReceiver.verificationStartError(error)
            case let .success(verification):
                self.verification = verification
                self.dataReceiver.verificationReceived(verification)
            }
        }
    }

    func submit(birthDate: Date) {
        guard let verification = verification else {
            return
        }
        let secret = birthDate.formatForJSONAPI()
        verification.secret = secret
        platform.completeVerification(verification) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.dataReceiver.verificationFailed()
            case let .success(verification):
                if verification.status == .passed {
                    verification.secret = secret
                    self.dataReceiver.verificationSucceeded(verification)
                } else {
                    self.dataReceiver.verificationFailed()
                }
            }
        }
    }
}
