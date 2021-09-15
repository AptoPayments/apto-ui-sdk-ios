//
//  CardSettingsModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit

class CardSettingsModule: UIModule, CardSettingsModuleProtocol {
  private let card: Card
  private let caller: PhoneCallerProtocol
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var presenter: CardSettingsPresenterProtocol?
  private var contentPresenterModule: ContentPresenterModuleProtocol?
  private let disposeBag = DisposeBag()

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
                                                      exchangeRates: cardProduct.exchangeRates,
                                                      showDetailedCardActivity: isShowDetailedInfoEnabled,
                                                      showMonthlyStatements: isShowMonthlyStatementsEnabled,
                                                      iapRowTitle: iapCardSettingRowTitle())
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
    
    private func dismissableContentPresenterModule(with content: Content,
                                        title: String) -> ContentPresenterModuleProtocol {
        let module = serviceLocator.moduleLocator.contentPresenterModule(content: content, title: title)
        module.onClose = { [unowned self] _ in
            self.dismissModule {
                self.contentPresenterModule = nil
            }
        }
        return module
    }
    
    private func iapCardSettingRowTitle() -> String {
        let checker = IAPCardEnrolmentChecker()
        if checker.isCardEnrolledInPhoneWallet(lastFourDigits: card.lastFourDigits) == false {
            return "card_settings.apple_pay.add_to_wallet.title".podLocalized()
        }
        if checker.isCardEnrolledInPairedWatchDevice(lastFourDigits: card.lastFourDigits) == false {
            return "card_settings.apple_pay.add_to_watch.title".podLocalized()
        }
        return ""
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

  func setPassCode() {
    guard card.state == .active else {
      self.show(message: "manage_card.confirm_pass_code.card_not_active.message".podLocalized(),
                title: "manage_card.confirm_pass_code.card_not_active.title".podLocalized(), isError: false)
      return
    }
    let viewModel = PassCodeOnboardingViewModel(card: card)
    let viewController = PassCodeOnboardingViewController(viewModel: viewModel, uiConfig: uiConfig)
    viewModel.navigator = PassCodeOnboardingNavigator(
      from: viewController,
      uiConfig: uiConfig,
      serviceLocator: serviceLocator
    )
    let navigationController = UINavigationController(rootViewController: viewController)
    present(viewController: navigationController, animated: true, embedInNavigationController: false) {}
    viewModel.output.moduleState.observeNext { [weak self] state in
      switch state {
      case .idle:
        self?.hideLoadingView()
      case .finished:
        self?.show(message: "manage_card.confirm_pass_code.pin_updated.message".podLocalized(),
                   title: "manage_card.confirm_pass_code.pin_updated.title".podLocalized(), isError: false)
      }
    }.dispose(in: disposeBag)
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

  func showCardInfo() {
    delegate?.showCardInfo()
  }

  func hideCardInfo() {
    delegate?.hideCardInfo()
  }

  func cardStateChanged(includingTransactions: Bool) {
    delegate?.cardStateChanged(includingTransactions: includingTransactions)
    close()
  }

  func show(content: Content, title: String) {
    let module = dismissableContentPresenterModule(with: content, title: title)
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

  func authenticate(completion: @escaping (Bool) -> Void) {
    let authenticationManager = serviceLocator.systemServicesLocator.authenticationManager()
    authenticationManager.authenticate(from: self, completion: completion)
  }
  
    func showAddFunds(for card: Card, extraContent: ExtraContent? = nil) {
        let viewController = addFundsUIComposer(with: card, extraContent: extraContent)
        navigationController?.pushViewController(viewController, animated: true, completion: nil)
    }
    
    private func addFundsUIComposer(with card: Card, extraContent: ExtraContent? = nil) -> AddFundsViewController {
        let viewModel = AddFundsViewModel(card: card)
        let viewController = AddFundsViewController(viewModel: viewModel, uiConfig: uiConfig)
        viewController.onPaymentSourceLoaded = {
            if LoadFundsOnBoardingHelper.shouldPresentOnBoarding() {
                
                let actionCompletion = { [weak self] in
                    if let addCardController = self?.addCardUIComposer() {
                        self?.present(viewController: addCardController, animated: true, embedInNavigationController: true, completion: {})
                    }
                }
                let closeCompletion: AddCardOnboardingViewController.CloseCompletionResult = { controller in
                    if let nc = controller.presentingViewController as? UINavigationController {
                        nc.popViewController(animated: false)
                    }
                }
                let controller = AddCardOnBoardingUIComposer.compose(with: card,
                                                                     extraContent: extraContent,
                                                                     platform: self.serviceLocator.platform,
                                                                     actionCompletion: actionCompletion,
                                                                     closeCompletion:  closeCompletion)
                self.present(viewController: controller, animated: true, embedInNavigationController: true, completion: {})
            }
        }
        let fundsNavigator = AddFundsNavigator(
            from: viewController,
            uiConfig: uiConfig,
            softDescriptor: card.features?.funding?.softDescriptor ?? "",
            cardNetworks: card.features?.funding?.cardNetworks ?? []
        )
        if let extraContent = extraContent,
           let content = extraContent.content {
            fundsNavigator.presentExtraContent = { [weak self] presenter in
                self?.presentExtraContent(from: presenter, content: content, title: extraContent.title)
            }
        }
        viewModel.navigator = fundsNavigator
        return viewController
    }
    
    private func addCardUIComposer() -> AddCardViewController {
        let cardNetworks = card.features?.funding?.cardNetworks ?? []
        let viewModel = AddCardViewModel(cardNetworks: cardNetworks)
        let controller = AddCardViewController(viewModel: viewModel, uiConfig: uiConfig, cardNetworks: cardNetworks)
        controller.closeCompletion = { addCardController in
            addCardController.dismiss(animated: true)
        }
        return controller
    }
    
    func showACHAccountAgreements(disclaimer: Content,
                                   cardId: String,
                                   acceptCompletion: @escaping () -> Void,
                                   declineCompletion: @escaping () -> Void) {
        let module = serviceLocator.moduleLocator.showACHAccountAgreements(disclaimer: disclaimer, cardId: cardId)
        module.onDeclineAgreements = { [weak self] in
            self?.dismissModule(animated: false, completion: {
                declineCompletion()
            })
        }
        module.onFinish = { [weak self] _ in
            self?.dismissModule(animated: false, completion: {
                acceptCompletion()
            })
        }
        present(module: module, leftButtonMode: .close) { _ in }
    }
    
    func showAddMoneyBottomSheet(card: Card, extraContent: ExtraContent? = nil) {
        let viewModel = AddMoneyViewModel(cardId: card.accountId, loader: serviceLocator.platform, analyticsManager: serviceLocator.analyticsManager)
        let addMoneyController = AddMoneyViewController(uiConfiguration: uiConfig, viewModel: viewModel)
        addMoneyController.directDepositAction = { [weak self] in
            guard let self = self else { return }
            let viewModel = DirectDepositViewModel(cardId: card.accountId,
                                                   loader: self.serviceLocator.platform,
                                                   analyticsManager: self.serviceLocator.analyticsManager)
            let controller = DirectDepositViewController(uiConfiguration: UIConfig.default, viewModel: viewModel)
            self.present(viewController: controller, animated: true, embedInNavigationController: true, completion: {})
        }
        addMoneyController.debitCardAction = { [weak self] in
            self?.showAddFunds(for: card, extraContent: extraContent)
        }
        addMoneyController.modalPresentationStyle = .overCurrentContext
        present(viewController: addMoneyController, completion: {})
    }
    
    // MARK: Private methods
    private func presentExtraContent(from presenter: UIViewController?, content: Content, title: String) {
        let module = dismissableContentPresenterModule(with: content, title: title)
        if let presenter = presenter {
            module.onClose = { _ in presenter.dismiss(animated: true) }
        }
        present(module: module, presenterController: presenter) { _ in }
    }

    func showOrderPhysicalCard(_ card: Card,
                               completion: OrderPhysicalCardUIComposer.OrderedCompletion? = nil) {
        let errorCompletion: OrderPhysicalCardUIComposer.CardConfigErrorCompletion = { [weak self] error in
            self?.show(error: error)
        }
        let viewController = OrderPhysicalCardUIComposer
            .composedWith(card: card,
                          cardLoader: serviceLocator.platform,
                          analyticsManager: serviceLocator.analyticsManager,
                          uiConfiguration: UIConfig.default,
                          cardOrderedCompletion: completion,
                          cardConfigErrorCompletion: errorCompletion)
        present(viewController: viewController, animated: true, embedInNavigationController: true, completion: {})
    }
    
    func showApplePayIAP(cardId: String, completion: ApplePayIAPUIComposer.IAPCompletion? = nil) {
        let viewController = ApplePayIAPUIComposer.composedWith(cardId: cardId,
                                                                cardLoader: serviceLocator.platform, uiConfiguration: UIConfig.default,
                                                                iapCompletion: completion)
        present(viewController: viewController, animated: true, completion: {})
    }
}
