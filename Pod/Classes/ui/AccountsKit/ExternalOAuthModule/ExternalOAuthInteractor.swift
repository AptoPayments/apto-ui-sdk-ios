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
  weak var presenter: ExternalOAuthPresenterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional

  private var attempt: OauthAttempt?

  init(platform: AptoPlatformProtocol) {
    self.platform = platform
  }

  func balanceTypeSelected(_ balanceType: AllowedBalanceType) {
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

  func verifyOauthAttemptStatus(callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    guard let attempt = self.attempt else { return }
    platform.verifyOauthAttemptStatus(attempt, callback: callback)
  }
}
