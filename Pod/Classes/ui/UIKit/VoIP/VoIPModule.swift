//
//  VoIPModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 19/06/2019.
//

import Foundation
import AptoSDK

class VoIPModule: UIModule, VoIPModuleProtocol {
  private let card: Card
  private let actionSource: VoIPActionSource
  private var presenter: VoIPPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card, actionSource: VoIPActionSource) {
    self.card = card
    self.actionSource = actionSource
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    completion(.success(buildViewController()))
  }

  func callFinished() {
    onFinish?(self)
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.voIPPresenter()
    let interactor = serviceLocator.interactorLocator.voIPInteractor(card: card, actionSource: actionSource)
    let analyticsManager = serviceLocator.analyticsManager
    presenter.router = self
    presenter.interactor = interactor
    presenter.analyticsManager = analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.voIPView(presenter: presenter)
  }
}
