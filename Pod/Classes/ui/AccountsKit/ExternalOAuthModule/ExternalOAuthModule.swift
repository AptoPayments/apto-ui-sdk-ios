//
//  ExternalOAuthModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation
import AptoSDK

class ExternalOAuthModule: UIModule, ExternalOAuthModuleProtocol {
  private let config: ExternalOAuthModuleConfig
  private var presenter: ExternalOAuthPresenterProtocol?
  private var dataConfirmationModule: DataConfirmationModuleProtocol?

  open var onOAuthSucceeded: ((_ externalOAuthModule: ExternalOAuthModuleProtocol, _ custodian: Custodian) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, config: ExternalOAuthModuleConfig, uiConfig: UIConfig) {
    self.config = config
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildExternalOAuthViewController(uiConfig)
    self.addChild(viewController: viewController, completion: completion)
  }

  fileprivate func buildExternalOAuthViewController(_ uiConfig: UIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.externalOAuthPresenter(config: config)
    var interactor = serviceLocator.interactorLocator.externalOAuthInteractor()
    let viewController = serviceLocator.viewLocator.externalOAuthView(uiConfiguration: uiConfig,
                                                                      eventHandler: presenter)
    presenter.interactor = interactor
    presenter.router = self
    interactor.presenter = presenter
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }
}

extension ExternalOAuthModule: ExternalOAuthRouterProtocol {
  func backInExternalOAuth(_ animated: Bool) {
    self.close()
  }

  func oauthSucceeded(_ custodian: Custodian) {
    onOAuthSucceeded?(self, custodian)
  }

  func show(url: URL, completion: @escaping () -> Void) {
    showExternal(url: url, completion: completion)
  }

  func showLoadingSpinner() {
    showLoadingSpinner(position: .center)
  }
}
