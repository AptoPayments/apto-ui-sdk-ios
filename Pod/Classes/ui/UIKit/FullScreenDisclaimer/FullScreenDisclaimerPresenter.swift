//
//  FullScreenDisclaimerPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import Foundation
import AptoSDK
import ReactiveKit

class FullScreenDisclaimerPresenter: FullScreenDisclaimerPresenterProtocol {
  let viewModel = FullScreenDisclaimerViewModel()
  weak var router: FullScreenDisclaimerRouterProtocol!
  var interactor: FullScreenDisclaimerInteractorProtocol!
  var analyticsManager: AnalyticsServiceProtocol?

  func viewLoaded() {
    interactor.provideDisclaimer { [weak self] disclaimer in
      self?.set(disclaimer: disclaimer)
    }
    analyticsManager?.track(event: Event.disclaimer)
  }

  private func set(disclaimer: Content) {
    viewModel.disclaimer.send(disclaimer)
  }

  func closeTapped() {
    router.close()
  }

  func agreeTapped() {
    router.agreeTapped()
  }

  func linkTapped(_ url: URL) {
    router.showExternal(url: url, headers: nil, useSafari: false, alternativeTitle: nil)
  }
}
