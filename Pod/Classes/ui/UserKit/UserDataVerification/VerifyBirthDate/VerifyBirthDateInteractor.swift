//
//  VerifyBirthDateInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 28/09/2016.
//
//

import Foundation
import AptoSDK

class VerifyBirthDateInteractor: VerifyBirthDateInteractorProtocol {
  private unowned let dataReceiver: VerifyBirthDateDataReceiver
  private let verificationType: VerificationParams<BirthDate, Verification>
  private let platform: AptoPlatformProtocol
  private var verification: Verification?
  private var birthDate: BirthDate?

  init(platform: AptoPlatformProtocol, verificationType: VerificationParams<BirthDate, Verification>,
       dataReceiver: VerifyBirthDateDataReceiver) {
    self.platform = platform
    self.dataReceiver = dataReceiver
    self.verificationType = verificationType
  }

  func provideBirthDate() {
    switch verificationType {
    case .datapoint(let birthDate):
      self.birthDate = birthDate
      startVerification()
    case .verification(let verification):
      self.verification = verification
      dataReceiver.verificationReceived(verification)
    }
  }

  func startVerification() {
    guard let birthDate = self.birthDate, birthDate.date.value != nil else {
      return
    }
    platform.startBirthDateVerification(birthDate) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.dataReceiver.verificationStartError(error)
      case .success(let verification):
        self.verification = verification
        self.dataReceiver.verificationReceived(verification)
      }
    }
  }

  func submit(birthDate: Date) {
    guard let verification = self.verification else {
      return
    }
    let secret = birthDate.formatForJSONAPI()
    verification.secret = secret
    platform.completeVerification(verification) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure:
        self.dataReceiver.verificationFailed()
      case .success(let verification):
        if verification.status == .passed {
          verification.secret = secret
          self.dataReceiver.verificationSucceeded(verification)
        }
        else {
          self.dataReceiver.verificationFailed()
        }
      }
    }
  }
}
