//
//  CreatePINModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import Foundation
import AptoSDK

class CreatePINModule: UIModule, CreatePINModuleProtocol {
  private var presenter: CreatePINPresenterProtocol?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.createPINPresenter()
    let interactor = serviceLocator.interactorLocator.createPINInteractor()
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.createPINView(presenter: presenter)
  }

  func show(url: TappedURL) {
    showExternal(url: url.url, alternativeTitle: url.title)
  }
}
