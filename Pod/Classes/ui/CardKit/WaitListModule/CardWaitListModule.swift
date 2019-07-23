//
// CardWaitListModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import AptoSDK

class CardWaitListModule: UIModule, CardWaitListModuleProtocol {
  private let card: Card
  private let cardProduct: CardProduct
  private var presenter: CardWaitListPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card, cardProduct: CardProduct) {
    self.card = card
    self.cardProduct = cardProduct
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  func cardStatusChanged() {
    onFinish?(self)
  }

  private func buildViewController() -> UIViewController {
    let interactor = serviceLocator.interactorLocator.cardWaitListInteractor(card: card)
    let config = WaitListActionConfiguration(asset: cardProduct.waitListAsset,
                                             backgroundImage: cardProduct.waitListBackgroundImage,
                                             backgroundColor: cardProduct.waitListBackgroundColor)
    let presenter = serviceLocator.presenterLocator.cardWaitListPresenter(config: config)
    presenter.interactor = interactor
    presenter.router = self
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.waitListView(presenter: presenter)
  }
}
