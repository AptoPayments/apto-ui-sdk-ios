//
//  FullScreenDisclaimerPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import AptoSDK
import Foundation
import ReactiveKit

class FullScreenDisclaimerPresenter: FullScreenDisclaimerPresenterProtocol {
    let viewModel = FullScreenDisclaimerViewModel()
    weak var router: FullScreenDisclaimerRouterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
    var interactor: FullScreenDisclaimerInteractorProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
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
