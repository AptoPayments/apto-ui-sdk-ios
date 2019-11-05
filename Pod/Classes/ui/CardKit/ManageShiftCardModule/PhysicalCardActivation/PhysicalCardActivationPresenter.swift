//
// PhysicalCardActivationPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-10.
//

import Foundation
import AptoSDK
import Bond

class PhysicalCardActivationPresenter: PhysicalCardActivationPresenterProtocol {
  private let notificationHandler: NotificationHandler
  let viewModel = PhysicalCardActivationViewModel()
  weak var router: PhysicalCardActivationModuleProtocol?
  var interactor: PhysicalCardActivationInteractorProtocol?
  var analyticsManager: AnalyticsServiceProtocol?
  private var card: Card?
  // swiftlint:disable:next weak_delegate
  private let cardActivationTextFieldDelegate = UITextFieldLengthLimiterDelegate(6)

  init(notificationHandler: NotificationHandler) {
    self.notificationHandler = notificationHandler
    registerToNotifications()
  }

  func viewLoaded() {
    router?.showLoadingView()
    interactor?.fetchCard { [weak self] result in
      guard let self = self else { return }
      self.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self.router?.show(error: error)
      case .success(let card):
        self.router?.showLoadingView()
        self.updateViewModel(with: card)
        self.card = card
        self.interactor?.fetchCurrentUser { [weak self] result in
          guard let self = self else { return }
          self.router?.hideLoadingView()
          switch result {
          case .failure(let error):
            self.router?.show(error: error)
          case .success(let user):
            self.updateViewModel(with: user)
          }
        }
      }
    }
  }

  func activateCardTapped() {
    guard let cardActivation = card?.features?.activation else { return }
    switch cardActivation.source {
    case .api:
      showPhysicalCardActivationByCode()
    case .voIP:
      break // Physical card activation via VoIP is not supported yet
    case .ivr(let ivr):
      if let url = PhoneHelper.sharedHelper().callURL(from: ivr.phone) {
        router?.call(url: url) {}
      }
    case .unknown:
      break
    }
  }

  func show(url: URL) {
    router?.show(url: url)
  }

  // MARK: - Private methods
  @objc private func didBecomeActive() {
    checkCardStatus()
  }

  private func registerToNotifications() {
    notificationHandler.addObserver(self, selector: #selector(didBecomeActive),
                                    name: UIApplication.didBecomeActiveNotification)
  }

  private func checkCardStatus() {
    router?.showLoadingView()
    interactor?.fetchUpdatedCard { [weak self] result in
      self?.router?.hideLoadingView()
      switch result {
      case .failure:
        break
      case .success(let card):
        guard let card = card else { return }
        if !(card.state == .created && card.orderedStatus == .ordered) {
          self?.unregisterFromNotifications()
          self?.router?.cardActivationFinish()
        }
      }
    }
  }

  private func unregisterFromNotifications() {
    notificationHandler.removeObserver(self)
  }

  private func updateViewModel(with card: Card) {
    viewModel.cardHolder.send(card.cardHolder)
    viewModel.cardStyle.send(card.cardStyle)
    viewModel.cardNetwork.send(card.cardNetwork)
  }

  private func updateViewModel(with user: ShiftUser) {
    viewModel.address.send(user.userData.addressDataPoint)
  }

  private func showPhysicalCardActivationByCode() {
    analyticsManager?.track(event: Event.manageCardActivatePhysicalCardOverlay)
    let cancelTitle = "manage_card.activate_physical_card_code.cancel".podLocalized()
    UIAlertController.prompt(title: "manage_card.activate_physical_card_code.title".podLocalized(),
                             message: "manage_card.activate_physical_card_code.message".podLocalized(),
                             placeholder: "manage_card.activate_physical_card_code.placeholder".podLocalized(),
                             keyboardType: .numberPad,
                             textFieldDelegate: cardActivationTextFieldDelegate,
                             okTitle: "manage_card.activate_physical_card_code.call_to_action".podLocalized(),
                             cancelTitle: cancelTitle) { [unowned self] code in
      guard let code = code, !code.isEmpty else { return }
      self.activatePhysicalCard(code: code)
    }
  }

  private func activatePhysicalCard(code: String) {
    router?.showLoadingSpinner()
    interactor?.activatePhysicalCard(code: code) { [unowned self] result in
      self.router?.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.router?.show(error: error)
      case .success:
        self.unregisterFromNotifications()
        self.router?.cardActivationFinish()
      }
    }
  }
}
