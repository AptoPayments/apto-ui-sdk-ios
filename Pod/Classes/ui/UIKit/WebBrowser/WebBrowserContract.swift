//
// WebBrowserContract.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/11/2018.
//

protocol WebBrowserRouterProtocol: AnyObject {
    func close()
}

protocol WebBrowserViewProtocol {
    func load(url: URL, headers: [String: String]?)
}

typealias WebBrowserViewControllerProtocol = AptoViewController & WebBrowserViewProtocol

protocol WebBrowserInteractorProtocol {
    func provideUrl()
}

protocol WebBrowserDataReceiverProtocol: AnyObject {
    func load(url: URL, headers: [String: String]?)
}

protocol WebBrowserEventHandlerProtocol: AnyObject {
    func viewLoaded()
    func closeTapped()
}

protocol WebBrowserPresenterProtocol: WebBrowserEventHandlerProtocol, WebBrowserDataReceiverProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var router: WebBrowserRouterProtocol! { get set }
    var view: WebBrowserViewProtocol! { get set }
    var interactor: WebBrowserInteractorProtocol! { get set }
    // swiftlint:enable implicitly_unwrapped_optional
}
