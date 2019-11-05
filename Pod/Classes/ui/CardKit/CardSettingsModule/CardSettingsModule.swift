//
//  CardSettingsModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//

import UIKit
import AptoSDK

class CardSettingsModule: UIModule, CardSettingsModuleProtocol {
  private let card: Card
  private let caller: PhoneCallerProtocol
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var presenter: CardSettingsPresenterProtocol?
  private var contentPresenterModule: ContentPresenterModuleProtocol?

  weak var delegate: CardSettingsModuleDelegate?

  public init(serviceLocator: ServiceLocatorProtocol, card: Card, phoneCaller: PhoneCallerProtocol) {
    self.card = card
    self.caller = phoneCaller
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    guard let cardProductId = card.cardProductId else {
      return completion(.failure(ServiceError(code: .internalIncosistencyError)))
    }
    platform.fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.platform.fetchCardProduct(cardProductId: cardProductId) { [weak self] result in
          guard let self = self else { return }
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let cardProduct):
            self.projectConfiguration = contextConfiguration.projectConfiguration
            let viewController = self.buildShiftCardSettingsViewController(self.uiConfig, cardProduct: cardProduct,
                                                                           card: self.card)
            self.addChild(viewController: viewController, completion: completion)
          }
        }
      }
    }
  }

  fileprivate func buildShiftCardSettingsViewController(_ uiConfig: UIConfig,
                                                        cardProduct: CardProduct,
                                                        card: Card) -> ShiftViewController {
    let isShowDetailedInfoEnabled = platform.isFeatureEnabled(.showDetailedCardActivityOption)
    let isShowMonthlyStatementsEnabled = platform.isFeatureEnabled(.showMonthlyStatementsOption)
    let presenterConfig = CardSettingsPresenterConfig(cardholderAgreement: cardProduct.cardholderAgreement,
                                                      privacyPolicy: cardProduct.privacyPolicy,
                                                      termsAndCondition: cardProduct.termsAndConditions,
                                                      faq: cardProduct.faq,
                                                      showDetailedCardActivity: isShowDetailedInfoEnabled,
                                                      showMonthlyStatements: isShowMonthlyStatementsEnabled)
    let recipients = [self.projectConfiguration.supportEmailAddress]
    let presenter = serviceLocator.presenterLocator.cardSettingsPresenter(card: card, config: presenterConfig,
                                                                          emailRecipients: recipients,
                                                                          uiConfig: uiConfig)
    let interactor = serviceLocator.interactorLocator.cardSettingsInteractor()
    let viewController = serviceLocator.viewLocator.cardSettingsView(presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }
}

extension CardSettingsModule: CardSettingsRouterProtocol {
  func closeFromShiftCardSettings() {
    close()
  }

  func changeCardPin() {
    let module = serviceLocator.moduleLocator.setPinModule(card: card)
    module.onClose = { [weak self] _ in
      self?.dismissModule {}
    }
    module.onFinish = { [weak self] _ in
      self?.dismissModule {}
      self?.show(message: "manage_card.confirm_pin.pin_updated.message".podLocalized(),
                 title: "manage_card.confirm_pin.pin_updated.title".podLocalized(), isError: false)
    }
    present(module: module) { _ in }
  }

  func showVoIP(actionSource: VoIPActionSource) {
    let module = serviceLocator.moduleLocator.voIPModule(card: card, actionSource: actionSource)
    module.onClose = { [weak self] _ in
      self?.dismissModule {}
    }
    module.onFinish = { [weak self] _ in
      self?.dismissModule {}
    }
    present(module: module) { _ in }
  }

  func call(url: URL, completion: @escaping () -> Void) {
    caller.call(phoneNumberURL: url, from: self, completion: completion)
  }

  func showCardInfo(completion: @escaping () -> Void) {
    delegate?.showCardInfo(completion: completion)
  }

  func hideCardInfo() {
    delegate?.hideCardInfo()
  }

  func isCardInfoVisible() -> Bool {
    return delegate?.isCardInfoVisible() ?? false
  }

  func cardStateChanged(includingTransactions: Bool) {
    delegate?.cardStateChanged(includingTransactions: includingTransactions)
  }

  func show(content: Content, title: String) {
    let module = serviceLocator.moduleLocator.contentPresenterModule(content: content, title: title)
    module.onClose = { [unowned self] _ in
      self.dismissModule {
        self.contentPresenterModule = nil
      }
    }
    contentPresenterModule = module
    present(module: module, leftButtonMode: .close) { _ in }
  }

  func showMonthlyStatements() {
    let module = serviceLocator.moduleLocator.monthlyStatementsList()
    module.onClose = { [weak self] _ in
      self?.popModule {}
    }
    push(module: module) { _ in }
  }
}
