//
//  CardSettingsPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation
import AptoSDK
import Bond

struct CardSettingsPresenterConfig {
  let cardholderAgreement: Content?
  let privacyPolicy: Content?
  let termsAndCondition: Content?
  let faq: Content?
  let showDetailedCardActivity: Bool
}

class CardSettingsPresenter: CardSettingsPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: CardSettingsViewProtocol!
  var interactor: CardSettingsInteractorProtocol!
  weak var router: CardSettingsRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel: CardSettingsViewModel
  var analyticsManager: AnalyticsServiceProtocol?
  private let card: Card
  private let rowsPerPage = 20
  private let enableCardAction: EnableCardAction
  private let disableCardAction: DisableCardAction
  private let showCardInfoAction: ShowCardInfoAction
  private let reportLostCardAction: ReportLostCardAction
  private let helpAction: HelpAction
  private let config: CardSettingsPresenterConfig
  private let phoneHelper = PhoneHelper.sharedHelper()

  init(platform: AptoPlatformProtocol,
       card: Card,
       config: CardSettingsPresenterConfig,
       emailRecipients: [String?],
       uiConfig: UIConfig) {
    self.card = card
    self.config = config
    self.viewModel = CardSettingsViewModel()
    self.enableCardAction = EnableCardAction(platform: platform, card: self.card, uiConfig: uiConfig)
    self.disableCardAction = DisableCardAction(platform: platform, card: self.card, uiConfig: uiConfig)
    self.reportLostCardAction = ReportLostCardAction(platform: platform, card: card, emailRecipients: emailRecipients,
                                                     uiConfig: uiConfig)
    self.showCardInfoAction = ShowCardInfoAction()
    self.helpAction = HelpAction(emailRecipients: emailRecipients)
    let legalDocuments = LegalDocuments(cardHolderAgreement: config.cardholderAgreement,
                                        faq: config.faq,
                                        termsAndConditions: config.termsAndCondition,
                                        privacyPolicy: config.privacyPolicy)
    self.viewModel.legalDocuments.next(legalDocuments)
  }

  func viewLoaded() {
    refreshData()
    analyticsManager?.track(event: Event.manageCardCardSettings)
  }

  func lockCardChanged(switcher: UISwitch) {
    if switcher.isOn {
      self.disableCardAction.run { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .failure(let error):
          self.viewModel.locked.next(false)
          switcher.isOn = false
          self.handleDisableCardError(error: error)
        case .success:
          self.viewModel.locked.next(true)
          self.router.cardStateChanged()
        }
      }
    }
    else {
      self.enableCardAction.run { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .failure(let error):
          self.viewModel.locked.next(true)
          self.handleEnableCardError(error: error)
        case .success:
          self.viewModel.locked.next(false)
          self.router.cardStateChanged()
        }
      }
    }
  }

  private func handleDisableCardError(error: NSError) {
    if let serviceError = error as? ServiceError, serviceError.isAbortedError {
      // The user aborted the operation, don't show an error message
      return
    }
    if let backendError = error as? BackendError, backendError.isCardDisableError {
      view.showClosedCardErrorAlert(title: "error.transport.shiftCardDisableError".podLocalized())
    }
    else {
      view.show(error: error)
    }
  }

  private func handleEnableCardError(error: NSError) {
    if let serviceError = error as? ServiceError, serviceError.isAbortedError {
      // The user aborted the operation, don't show an error message
      return
    }
    if let backendError = error as? BackendError, backendError.isCardEnableError {
      self.view.showClosedCardErrorAlert(title: "error.transport.shiftCardEnableError".podLocalized())
    }
    else {
      self.view.show(error: error)
    }
  }

  func updateCardNewStatus() {
    self.router.cardStateChanged()
    self.router.closeFromShiftCardSettings()
  }

  func showCardInfoChanged(switcher: UISwitch) {
    if switcher.isOn {
      self.showCardInfoAction.run { [weak self] accessGranted in
        guard let self = self else { return }
        if !accessGranted {
          self.viewModel.showCardInfo.next(false)
        }
        else {
          self.view.showLoadingSpinner()
          self.router.showCardInfo() { [weak self] in
            self?.view.hideLoadingSpinner()
            self?.router.closeFromShiftCardSettings()
          }
        }
      }
    }
    else {
      viewModel.showCardInfo.next(false)
      router.hideCardInfo()
    }
  }

  fileprivate func refreshData() {
    if let setPin = card.features?.setPin, setPin.status == .enabled {
      viewModel.showChangePin.next(true)
    }
    else {
      viewModel.showChangePin.next(false)
    }
    if let getPin = card.features?.getPin, getPin.status == .enabled {
      viewModel.showGetPin.next(true)
    }
    else {
      viewModel.showGetPin.next(false)
    }
    viewModel.locked.next(card.state != .active)
    viewModel.showCardInfo.next(router.isCardInfoVisible())
    viewModel.showIVRSupport.next(card.features?.ivrSupport?.status == .enabled)
    viewModel.isShowDetailedCardActivityEnabled.next(interactor.isShowDetailedCardActivityEnabled())
    viewModel.showDetailedCardActivity.next(config.showDetailedCardActivity)
  }

  func closeTapped() {
    router.closeFromShiftCardSettings()
  }

  func callIvrTapped() {
    guard let url = phoneHelper.callURL(from: card.features?.ivrSupport?.phone) else { return }
    router.call(url: url) {}
  }

  func helpTapped() {
    helpAction.run()
  }

  func lostCardTapped() {
    reportLostCardAction.run { [unowned self] result in
      switch result {
      case .failure(let error):
        if let serviceError = error as? ServiceError, serviceError.code == ServiceError.ErrorCodes.aborted.rawValue {
          // User aborted, do nothing
          return
        }
        self.view.show(error: error)
      case .success:
        self.viewModel.locked.next(true)
        self.router.cardStateChanged()
      }
    }
  }

  func changePinTapped() {
    router.changeCardPin()
  }

  func getPinTapped() {
    guard let actionSource = card.features?.getPin?.source else { return }
    switch actionSource {
    case .voIP:
      router.showVoIP(actionSource: .getPin)
    case .api:
      break // Get pin via API is not supported yet
    case .ivr(let ivr):
      guard let url = phoneHelper.callURL(from: ivr.phone) else { return }
      router.call(url: url) { [unowned self] in
        self.router.cardStateChanged()
      }
    case .unknown:
      break
    }
  }

  func show(content: Content, title: String) {
    router.show(content: content, title: title)
  }

  func showDetailedCardActivity(_ newValue: Bool) {
    interactor.setShowDetailedCardActivityEnabled(newValue)
    router.cardStateChanged(includingTransactions: true)
  }
}
