//
//  CreatePasscodeModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import Foundation
import AptoSDK

class CreatePasscodeModule: UIModule, CreatePasscodeModuleProtocol {
  private var presenter: CreatePasscodePresenterProtocol?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.createPasscodePresenter()
    let interactor = serviceLocator.interactorLocator.createPasscodeInteractor()
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.createPasscodeView(presenter: presenter)
  }
}
