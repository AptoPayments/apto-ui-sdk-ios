//
// FullScreenDisclaimerContract.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 15/11/2018.
//

import AptoSDK
import Bond

protocol FullScreenDisclaimerRouterProtocol: AnyObject {
    func close()
    func showExternal(url: URL, headers: [String: String]?, useSafari: Bool?, alternativeTitle: String?)
    func agreeTapped()
}

protocol FullScreenDisclaimerInteractorProtocol {
    func provideDisclaimer(completion: @escaping ((_ disclaimer: Content) -> Void))
}

class FullScreenDisclaimerViewModel {
    var disclaimer: Observable<Content?> = Observable(nil)
}

protocol FullScreenDisclaimerEventHandler: AnyObject {
    var viewModel: FullScreenDisclaimerViewModel { get }
    func viewLoaded()
    func closeTapped()
    func agreeTapped()
    func linkTapped(_ url: URL)
}

protocol FullScreenDisclaimerPresenterProtocol: FullScreenDisclaimerEventHandler {
    // swiftlint:disable implicitly_unwrapped_optional
    var router: FullScreenDisclaimerRouterProtocol! { get set }
    var interactor: FullScreenDisclaimerInteractorProtocol! { get set }
    // swiftlint:enable implicitly_unwrapped_optional
    var analyticsManager: AnalyticsServiceProtocol? { get set }
}

protocol FullScreenDisclaimerModuleProtocol: UIModuleProtocol {
    var onDisclaimerAgreed: ((_ fullScreenDisclaimerModule: FullScreenDisclaimerModuleProtocol) -> Void)? { get set }
}
