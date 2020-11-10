//
// SetPinModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import Foundation
import AptoSDK

class SetPinModule: UIModule, SetPinModuleProtocol {
  private let card: Card
  private var presenter: SetPinPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card) {
    self.card = card
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    completion(.success(buildViewController()))
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.setPinPresenter()
    let interactor = serviceLocator.interactorLocator.setPinInteractor(card: card)
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.setPinView(presenter: presenter)
  }

  func pinChanged() {
    finish()
  }
}
