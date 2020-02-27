//
// CardWaitListModule.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import AptoSDK

class CardWaitListModule: UIModule, CardWaitListModuleProtocol {
  private let card: Card
  private var presenter: CardWaitListPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card) {
    self.card = card
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let cardProductId = card.cardProductId else {
      completion(.failure(ServiceError(code: .internalIncosistencyError)))
      return
    }
    platform.fetchCardProduct(cardProductId: cardProductId, forceRefresh: false) { [weak self] result  in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let cardProduct):
        guard let self = self else { return }
        let viewController = self.buildViewController(cardProduct: cardProduct)
        completion(.success(viewController))
      }
    }
  }

  func cardStatusChanged() {
    onFinish?(self)
  }

  private func buildViewController(cardProduct: CardProduct) -> UIViewController {
    let interactor = serviceLocator.interactorLocator.cardWaitListInteractor(card: card)
    let config = WaitListActionConfiguration(asset: cardProduct.waitListAsset,
                                             backgroundImage: cardProduct.waitListBackgroundImage,
                                             backgroundColor: cardProduct.waitListBackgroundColor,
                                             darkBackgroundColor: cardProduct.waitListDarkBackgroundColor)
    let presenter = serviceLocator.presenterLocator.cardWaitListPresenter(config: config)
    presenter.interactor = interactor
    presenter.router = self
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.waitListView(presenter: presenter)
  }
}
