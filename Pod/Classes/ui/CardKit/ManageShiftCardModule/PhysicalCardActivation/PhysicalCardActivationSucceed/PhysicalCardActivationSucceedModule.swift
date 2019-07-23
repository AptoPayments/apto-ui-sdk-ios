//
//  PhysicalCardActivationSucceedModule.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import Foundation
import AptoSDK

class PhysicalCardActivationSucceedModule: UIModule, PhysicalCardActivationSucceedModuleProtocol {
  private let card: Card
  private let caller: PhoneCallerProtocol
  private var presenter: PhysicalCardActivationSucceedPresenterProtocol?

  init(serviceLocator: ServiceLocatorProtocol, card: Card, phoneCaller: PhoneCallerProtocol) {
    self.card = card
    self.caller = phoneCaller
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildViewController(uiConfig: uiConfig)
    completion(.success(viewController))
  }

  func call(url: URL, completion: @escaping () -> Void) {
    caller.call(phoneNumberURL: url, from: self, completion: completion)
  }

  func showSetPin() {
    let module = serviceLocator.moduleLocator.setPinModule(card: card)
    module.onClose = { [weak self] _ in
      self?.dismissModule {}
    }
    module.onFinish = { [weak self] _ in
      self?.dismissModule(animated: false) {}
      self?.show(message: "manage_card.confirm_pin.pin_created.message".podLocalized(),
                 title: "manage_card.confirm_pin.pin_created.title".podLocalized(), isError: false)
      self?.getPinFinished()
    }
    present(module: module) { _ in }
  }

  func showVoIP() {
    let module = serviceLocator.moduleLocator.voIPModule(card: card, actionSource: .getPin)
    module.onClose = { [weak self] _ in
      self?.dismissModule {}
    }
    module.onFinish = { [weak self] _ in
      self?.dismissModule {}
      self?.getPinFinished()
    }
    present(module: module) { _ in }
  }

  func getPinFinished() {
    onFinish?(self)
  }

  private func buildViewController(uiConfig: UIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.physicalCardActivationSucceedPresenter()
    let viewController = serviceLocator.viewLocator.physicalCardActivationSucceedView(uiConfig: uiConfig,
                                                                                      presenter: presenter)
    let interactor = serviceLocator.interactorLocator.physicalCardActivationSucceedInteractor(card: card)
    presenter.interactor = interactor
    presenter.router = self
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }
}
