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
    self.addChild(viewController: viewController, completion: completion)
    self.presenter = presenter
  }
}

extension WebBrowserModule: WebBrowserRouterProtocol {
}

extension UIModule {
  open func showExternal(url: URL,
                         headers: [String: String]? = nil,
                         useSafari: Bool? = false,
                         alternativeTitle: String? = nil,
                         completion: (() -> ())?) {
    if useSafari == true {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    else {
      let webBrowserModule = serviceLocator.moduleLocator.webBrowserModule(url: url,
                                                                           headers: headers,
                                                                           alternativeTitle: alternativeTitle)
      webBrowserModule.onClose = { [weak self] module in
        self?.dismissModule {
          completion?()
        }
      }
      self.present(module: webBrowserModule) { _ in }
    }
  }

  open func showExternal(url: URL,
                         headers: [String: String]? = nil,
                         useSafari: Bool? = false,
                         alternativeTitle: String? = nil) {
    showExternal(url: url, headers: headers, useSafari: useSafari, alternativeTitle: alternativeTitle, completion: nil)
  }
}
