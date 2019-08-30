//
//  ExternalOAuthInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation
import AptoSDK

class ExternalOAuthInteractor: ExternalOAuthInteractorProtocol {
  private let platform: AptoPlatformProtocol
  weak var presenter: ExternalOAuthPresenterProtocol!

  private var attempt: OauthAttempt?
  private var custodianType: String?

  init(platform: AptoPlatformProtocol) {
    self.platform = platform
  }

  func balanceTypeSelected(_ balanceType: AllowedBalanceType) {
    custodianType = balanceType.type
    platform.startOauthAuthentication(balanceType: balanceType) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.presenter.show(error: error)
      case .success(let attempt):
        self.attempt = attempt
        self.presenter.show(url: attempt.url!) // swiftlint:disable:this force_unwrapping
      }
    }
  }

  func verifyOauthAttemptStatus(callback: @escaping Result<Custodian, NSError>.Callback) {
    guard let attempt = self.attempt, let custodianType = self.custodianType else {
      return
    }
    platform.verifyOauthAttemptStatus(attempt, custodianType: custodianType) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.presenter.show(error: error)
      case .success(let custodian):
        self.presenter.custodianStatusUpdated(custodian)
      }
    }
  }
}
