//
//  ManageShiftCardModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 08/03/2018.
//

import UIKit
import AptoSDK
import MapKit

class ManageShiftCardModule: UIModule {
  private var card: Card
  private let mode: ShiftCardModuleMode
  private var shiftCardSettingsModule: CardSettingsModuleProtocol?
  private var accountSettingsModule: UIModuleProtocol?
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var mailSender: MailSender?
  private var cardConfiguration: CardConfiguration?
  private var presenter: ManageShiftCardPresenterProtocol?
  private var kycPresenter: KYCPresenterProtocol?
  private var transactionDetailsPresenter: ShiftCardTransactionDetailsPresenterProtocol?
  private var physicalCardActivationSucceedModule: PhysicalCardActivationSucceedModuleProtocol?
  private var physicalCardActivationModule: PhysicalCardActivationModuleProtocol?
  private var fundingSourceSelectorModule: FundingSourceSelectorModuleProtocol?
  private var cardMonthlyStatsModule: CardMonthlyStatsModuleProtocol?
  private var cardWaitListModule: CardWaitListModuleProtocol?

  public init(serviceLocator: ServiceLocatorProtocol, card: Card, mode: ShiftCardModuleMode) {
    self.card = card
    self.mode = mode
    super.init(serviceLocator: serviceLocator)
    self.registerForNotifications()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    platform.fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.projectConfiguration = contextConfiguration.projectConfiguration
        // Refresh the card data
        self.platform.fetchFinancialAccount(self.card.accountId, forceRefresh: false,
                                            retrieveBalances: false) { [weak self] result in
          guard let self = self else { return }
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let financialAccount):
            guard let card = financialAccount as? Card, let cardProductId = card.cardProductId else {
              return
            }
            self.card = card
            self.platform.fetchCardConfiguration(cardProductId: cardProductId) { [weak self] result in
              guard let self = self else { return }
              switch result {
              case .failure(let error):
                completion(.failure(error))
              case .success(let cardConfiguration):
                self.cardConfiguration = cardConfiguration
                if let kyc = self.card.kyc {
                  switch kyc {
                  case .passed:
                    self.showManageCard(addChild: true, cardConfiguration: cardConfiguration, completion: completion)
                  default:
                    self.showKYCViewController(addChild: true, card: self.card, completion: completion)
                  }
                }
                else {
                  self.showManageCard(addChild: true, cardConfiguration: cardConfiguration, completion: completion)
                }
              }
            }
          }
        }
      }
    }
  }

  private func registerForNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.kycInvalidated),
                                           name: .KYCNotPassedNotification,
                                           object: nil)
  }

  private var isPresentingModalKYC = false
  @objc private func kycInvalidated() {
    guard isPresentingModalKYC == false else { return }
    isPresentingModalKYC = true
    let viewController = self.buildKYCViewController(uiConfig, card: card)
    UIApplication.topViewController()?.present(viewController, animated: true)
  }

  // MARK: - Manage Card View Controller

  private func showManageCard(addChild: Bool,
                              cardConfiguration: CardConfiguration,
                              completion: @escaping Result<UIViewController, NSError>.Callback) {
    if card.isInWaitList == true {
      showWaitListModule(addChild: addChild, cardConfiguration: cardConfiguration, completion: completion)
    }
    else if card.state == .created && card.orderedStatus == .ordered {
      showPhysicalCardActivationModule(addChild: addChild, completion: completion)
    }
    else {
      showManageCardViewController(addChild: addChild, completion: completion)
    }
  }

  private func showWaitListModule(addChild: Bool,
                                  cardConfiguration: CardConfiguration,
                                  completion: @escaping Result<UIViewController, NSError>.Callback) {
    let cardProduct = cardConfiguration.cardProduct
    let module = serviceLocator.moduleLocator.cardWaitListModule(card: card, cardProduct: cardProduct)
    self.cardWaitListModule = module
    if addChild {
      module.onFinish = { [weak self] _ in
        self?.reloadCardAndShowManageCardIfPossible { _ in }
      }
      self.addChild(module: module, completion: completion)
    }
    else {
      module.onFinish = { [weak self] _ in
        self?.dismissModule {
          self?.reloadCardAndShowManageCardIfPossible { _ in }
        }
      }
      present(module: module, embedInNavigationController: false, completion: completion)
    }
  }

  private func showPhysicalCardActivationModule(addChild: Bool,
                                                completion: @escaping Result<UIViewController, NSError>.Callback) {
    let module = serviceLocator.moduleLocator.physicalCardActivationModule(card: card)
    self.physicalCardActivationModule = module
    if addChild {
      module.onFinish = { [weak self] _ in
        self?.reloadCardAndShowManageCardIfPossible {_ in }
      }
      self.addChild(module: module, completion: completion)
    }
    else {
      module.onFinish = { [weak self] _ in
        self?.reloadCardAndShowManageCardIfPossible {_ in }
      }
      push(module: module, completion: completion)
    }
  }

  private func reloadCardAndShowManageCardIfPossible(completion: @escaping Result<UIViewController, NSError>.Callback) {
    showLoadingView()
    platform.fetchFinancialAccount(card.accountId, forceRefresh: true, retrieveBalances: false) { [weak self] result in
      guard let self = self else { return }
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let financialAccount):
        guard let shiftCard = financialAccount as? Card else {
          return
        }
        // Clean up memory
        self.physicalCardActivationModule = nil
        self.cardWaitListModule = nil
        self.card = shiftCard
        if !(shiftCard.state == .created && shiftCard.orderedStatus == .ordered) {
          self.showManageCardViewController(addChild: false, completion: completion)
        }
      }
    }
  }

  fileprivate func showManageCardViewController(addChild: Bool = false,
                                                completion: @escaping Result<UIViewController, NSError>.Callback) {
    // swiftlint:disable:next force_unwrapping
    let viewController = self.buildManageShiftCardViewController(uiConfig, card: card)
    if addChild {
      self.addChild(viewController: viewController, completion: completion)
    }
    else {
      self.push(viewController: viewController) {
        completion(.success(viewController))
      }
    }
  }

  fileprivate func buildManageShiftCardViewController(_ uiConfig: UIConfig,
                                                      card: Card) -> ManageShiftCardViewControllerProtocol {
    let showActivateCardButton = platform.isFeatureEnabled(.showActivateCardButton)
    let showStatsButton = platform.isFeatureEnabled(.showStatsButton)
    let config = ManageShiftCardPresenterConfig(name: projectConfiguration.name,
                                                imageUrl: projectConfiguration.branding.logoUrl,
                                                showActivateCardButton: showActivateCardButton,
                                                showStatsButton: showStatsButton)
    let presenter = serviceLocator.presenterLocator.manageCardPresenter(config: config)
    let interactor = serviceLocator.interactorLocator.manageCardInteractor(card: card)
    let viewController = serviceLocator.viewLocator.manageCardView(mode: mode, presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }

  // MARK: - KYCView Controller

  fileprivate func showKYCViewController(addChild: Bool = false,
                                         card: Card,
                                         completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = self.buildKYCViewController(uiConfig, card: card)
    if addChild {
      let leftButtonMode: UIViewControllerLeftButtonMode = self.mode == .standalone ? .none : .close
      self.addChild(viewController: viewController, leftButtonMode: leftButtonMode, completion: completion)
    }
    else {
      self.push(viewController: viewController) {
        completion(.success(viewController))
      }
    }
  }

  fileprivate func buildKYCViewController(_ uiConfig: UIConfig, card: Card) -> KYCViewControllerProtocol {
    let presenter = serviceLocator.presenterLocator.kycPresenter()
    let interactor = serviceLocator.interactorLocator.kycInteractor(card: card)
    let viewController = serviceLocator.viewLocator.kycView(presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    self.kycPresenter = presenter
    return viewController
  }
}

extension ManageShiftCardModule: ManageShiftCardRouterProtocol {
  func update(card newCard: Card) {
    if newCard.state != .cancelled {
      self.card = newCard
    }
    else {
      // Card has been cancelled, look for other user cards that are not closed, if any. If there are no non-closed
      // cards, close the SDK
      self.showLoadingView()
      platform.fetchCards(page: 0, rows: 100) { [unowned self] result in
        self.hideLoadingView()
        switch result {
        case .failure(let error):
          // Close the SDK
          self.show(error: error)
          self.close()
        case .success(let cards):
          let nonClosedCards = cards.filter { $0.state != .cancelled }
          if let card = nonClosedCards.first, let cardConfiguration = self.cardConfiguration {
            self.card = card
            self.showManageCard(addChild: false, cardConfiguration: cardConfiguration) { _ in }
          }
          else {
            // Close the SDK
            self.close()
          }
        }
      }
    }
  }

  func closeFromManageShiftCardViewer() {
    self.close()
  }

  func accountSettingsTappedInManageShiftCardViewer() {
    let module = serviceLocator.moduleLocator.accountSettingsModule()
    module.onClose = { [weak self] module in
      self?.dismissModule {
        self?.accountSettingsModule = nil
      }
    }
    self.accountSettingsModule = module
    present(module: module) { _ in }
  }

  func cardSettingsTappedInManageShiftCardViewer() {
    let module = serviceLocator.moduleLocator.cardSettingsModule(card: card)
    module.onClose = { [weak self] module in
      guard self?.shiftCardSettingsModule != nil else { return }
      self?.shiftCardSettingsModule = nil
      self?.dismissModule {}
    }
    self.shiftCardSettingsModule = module
    module.delegate = self
    present(module: module) { _ in }
  }

  func balanceTappedInManageShiftCardViewer() {
    guard card.features?.allowedBalanceTypes?.isEmpty == false else { return }
    let module = serviceLocator.moduleLocator.fundingSourceSelector(card: card)
    module.onClose = { [weak self] _ in
      self?.dismissModule {
        self?.fundingSourceSelectorModule = nil
        self?.presenter?.refreshFundingSource()
      }
    }
    module.onFinish = { [weak self] _ in
      self?.dismissModule {
        self?.fundingSourceSelectorModule = nil
        self?.presenter?.refreshFundingSource()
      }
    }
    self.fundingSourceSelectorModule = module
    present(module: module, embedInNavigationController: false) { _ in }
  }

  func showCardStatsTappedInManageCardViewer() {
    let module = serviceLocator.moduleLocator.cardMonthlyStatsModule(card: card)
    module.onClose = { [weak self] _ in
      self?.dismissModule {
        self?.cardMonthlyStatsModule = nil
      }
    }
    self.cardMonthlyStatsModule = module
    present(module: module) { _ in }
  }

  func showTransactionDetails(transaction: Transaction) {
    let viewController = buildTransactionDetailsViewControllerFor(uiConfig, transaction: transaction)
    self.present(viewController: viewController, embedInNavigationController: true) {}
  }

  func physicalActivationSucceed() {
    let physicalCardModule = serviceLocator.moduleLocator.physicalCardActivationSucceedModule(card: card)
    physicalCardModule.onClose = { [unowned self] _ in
      self.dismissModule { [unowned self] in
        self.physicalCardActivationSucceedModule = nil
        self.presenter?.refreshCard()
      }
    }
    physicalCardModule.onFinish = { [unowned self] _ in
      self.dismissModule { [unowned self] in
        self.physicalCardActivationSucceedModule = nil
        self.presenter?.refreshCard()
      }
    }
    present(module: physicalCardModule) { _ in }
    self.physicalCardActivationSucceedModule = physicalCardModule
  }

  fileprivate func buildTransactionDetailsViewControllerFor(_ uiConfig: UIConfig,
                                                            transaction: Transaction) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.transactionDetailsPresenter()
    let interactor = serviceLocator.interactorLocator.transactionDetailsInteractor(transaction: transaction)
    let viewController = serviceLocator.viewLocator.transactionDetailsView(presenter: presenter)
    presenter.interactor = interactor
    presenter.router = self
    presenter.view = viewController
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.transactionDetailsPresenter = presenter
    return viewController
  }
}

extension ManageShiftCardModule: ShiftCardTransactionDetailsRouterProtocol {
  func backFromTransactionDetails() {
    self.dismissViewController {}
  }
}

extension UIModule {
  func openMapsCenteredIn(latitude: Double, longitude: Double) {
    let regionDistance: CLLocationDistance = 10000
    let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
    let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance,
                                        longitudinalMeters: regionDistance)
    let options = [
      MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
      MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
    ]
    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = ""
    mapItem.openInMaps(launchOptions: options)
  }
}

extension ManageShiftCardModule: KYCRouterProtocol {
  func closeFromKYC() {
    self.close()
  }

  func kycPassed() {
    if let cardConfiguration = self.cardConfiguration {
      platform.fetchFinancialAccount(self.card.accountId, forceRefresh: true,
                                     retrieveBalances: false) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .failure(let error):
          self.show(error: error)
        case .success(let financialAccount):
          guard let shiftCard = financialAccount as? Card else {
            return
          }
          self.card = shiftCard
          if self.isPresentingModalKYC {
            self.isPresentingModalKYC = false
            UIApplication.topViewController()?.dismiss(animated: true)
            self.platform.runPendingNetworkRequests()
          }
          else {
            self.popViewController(animated: false) {
              self.showManageCard(addChild: false, cardConfiguration: cardConfiguration) { _ in }
            }
          }
        }
      }
    }
  }

  func show(url: URL) {
    showExternal(url: url, useSafari: true)
  }
}

extension ManageShiftCardModule: CardSettingsModuleDelegate {
  func showCardInfo(completion: @escaping () -> Void) {
    presenter?.showCardInfo(completion: completion)
  }

  func hideCardInfo() {
    presenter?.hideCardInfo()
  }

  func isCardInfoVisible() -> Bool {
    return presenter?.viewModel.cardInfoVisible.value ?? false
  }

  func cardStateChanged(includingTransactions: Bool) {
    if includingTransactions {
      presenter?.reloadTapped(showSpinner: false)
    }
    else {
      presenter?.refreshCard()
    }
  }
}
