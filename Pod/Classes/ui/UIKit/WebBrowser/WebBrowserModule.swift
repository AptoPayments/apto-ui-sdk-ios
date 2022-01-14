//
//  WebBrowserModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 14/10/2016.
//
//

import Foundation

class WebBrowserModule: UIModule {
    private let url: URL
    private let headers: [String: String]?
    private let alternativeTitle: String?
    private var presenter: WebBrowserPresenterProtocol?

    init(serviceLocator: ServiceLocatorProtocol, url: URL, headers: [String: String]? = nil, alternativeTitle: String?) {
        self.url = url
        self.headers = headers
        self.alternativeTitle = alternativeTitle
        super.init(serviceLocator: serviceLocator)
    }

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let presenter = serviceLocator.presenterLocator.webBrowserPresenter()
        let interactor = serviceLocator.interactorLocator.webBrowserInteractor(url: url,
                                                                               headers: headers,
                                                                               dataReceiver: presenter)
        let viewController = serviceLocator.viewLocator.webBrowserView(alternativeTitle: alternativeTitle,
                                                                       eventHandler: presenter)
        presenter.interactor = interactor
        presenter.router = self
        presenter.view = viewController
        addChild(viewController: viewController, completion: completion)
        self.presenter = presenter
    }
}

extension WebBrowserModule: WebBrowserRouterProtocol {}
