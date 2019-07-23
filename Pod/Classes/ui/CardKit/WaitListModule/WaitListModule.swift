//
//  WaitListModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 27/02/2019.
//

import AptoSDK

class WaitListModule: UIModule, WaitListModuleProtocol {
  private let cardApplication: CardApplication
  private var presenter: WaitListPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, cardApplication: CardApplication) {
    self.cardApplication = cardApplication
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  func applicationStatusChanged() {
    onFinish?(self)
  }

  private func buildViewController() -> UIViewController {
    let interactor = serviceLocator.interactorLocator.waitListInteractor(application: cardApplication)
    let config = (cardApplication.nextAction.configuration as? WaitListActionConfiguration) ?? nil
    let presenter = serviceLocator.presenterLocator.waitListPresenter(config: config)
    presenter.interactor = interactor
    presenter.router = self
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return serviceLocator.viewLocator.waitListView(presenter: presenter)
  }
}
