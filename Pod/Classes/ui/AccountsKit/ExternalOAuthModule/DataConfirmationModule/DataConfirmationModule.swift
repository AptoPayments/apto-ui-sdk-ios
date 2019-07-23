//
//  DataConfirmationModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

import AptoSDK

class DataConfirmationModule: UIModule, DataConfirmationModuleProtocol {
  private var userData: DataPointList
  private var presenter: DataConfirmationPresenterProtocol?

  var delegate: DataConfirmationModuleDelegate?

  init(serviceLocator: ServiceLocatorProtocol, userData: DataPointList) {
    self.userData = userData
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController(uiConfig)
    addChild(viewController: viewController, completion: completion)
  }

  private func buildViewController(_ config: UIConfig) -> UIViewController {
    let interactor = serviceLocator.interactorLocator.dataConfirmationInteractor(userData: userData)
    let presenter = serviceLocator.presenterLocator.dataConfirmationPresenter()
    presenter.interactor = interactor
    presenter.router = self
    presenter.analyticsManager = serviceLocator.analyticsManager
    let viewController = serviceLocator.viewLocator.dataConfirmationView(uiConfig: config, presenter: presenter)
    self.presenter = presenter
    return viewController
  }

  func confirmData() {
    onFinish?(self)
  }

  func show(url: URL) {
    showExternal(url: url)
  }

  func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback) {
    delegate?.reloadUserData(callback: callback)
  }

  func updateUserData(_ userData: DataPointList) {
    self.userData = userData
    presenter?.updateUserData(userData)
  }
}
