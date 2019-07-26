//
//  ExternalOAuthPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation
import AptoSDK

class ExternalOAuthPresenter: ExternalOAuthPresenterProtocol {

  let config: ExternalOAuthModuleConfig
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: ExternalOAuthInteractorProtocol!
  weak var router: ExternalOAuthRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = ExternalOAuthViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: ExternalOAuthModuleConfig) {
    self.config = config
  }

  func viewLoaded() {
    viewModel.title.send(config.title)
    viewModel.allowedBalanceTypes.send(config.allowedBalanceTypes)
    analyticsManager?.track(event: Event.selectBalanceStoreLogin)
  }

  func balanceTypeTapped(_ balanceType: AllowedBalanceType) {
    router.showLoadingView()
    interactor.balanceTypeSelected(balanceType)
    analyticsManager?.track(event: Event.selectBalanceStoreLoginConnectTap)
  }

  func closeTapped() {
    router.backInExternalOAuth(true)
  }

  func show(error: NSError) {
    viewModel.error.send(error)
  }

  func show(url: URL) {
    router.hideLoadingView()
    router.show(url: url) { [weak self] in
      self?.router.showLoadingView()
      self?.interactor.verifyOauthAttemptStatus() { _ in
        self?.router.hideLoadingView()
      }
    }
  }

  func newUserTapped(url: URL) {
    router.show(url: url) {}
  }

  func custodianStatusUpdated(_ custodian: Custodian?) {
    router.hideLoadingView()
    if let custodian = custodian {
      router.oauthSucceeded(custodian)
    }
  }
}
