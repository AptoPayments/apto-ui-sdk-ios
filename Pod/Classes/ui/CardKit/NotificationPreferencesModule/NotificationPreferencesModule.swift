//
//  NotificationPreferencesModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/03/2019.
//

class NotificationPreferencesModule: UIModule, NotificationPreferencesModuleProtocol {
  private var presenter: NotificationPreferencesPresenterProtocol?

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController()
    completion(.success(viewController))
  }

  private func buildViewController() -> UIViewController {
    let presenter = serviceLocator.presenterLocator.notificationPreferencesPresenter()
    let viewController = serviceLocator.viewLocator.notificationPreferencesView(presenter: presenter)
    presenter.interactor = serviceLocator.interactorLocator.notificationPreferencesInteractor()
    presenter.router = self
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }
}
