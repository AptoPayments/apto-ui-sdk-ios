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
  let viewModel = PhysicalCardActivationViewModel()
  weak var router: PhysicalCardActivationModuleProtocol?
  var interactor: PhysicalCardActivationInteractorProtocol?
  var analyticsManager: AnalyticsServiceProtocol?
  private var card: Card?
  private let cardActivationTextFieldDelegate = UITextFieldLengthLimiterDelegate(6)

  init() {
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
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(didBecomeActive),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
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
    NotificationCenter.default.removeObserver(self)
  }

  private func updateViewModel(with card: Card) {
    viewModel.cardHolder.next(card.cardHolder)
    viewModel.cardStyle.next(card.cardStyle)
    viewModel.cardNetwork.next(card.cardNetwork)
  }

  private func updateViewModel(with user: ShiftUser) {
    viewModel.address.next(user.userData.addressDataPoint)
  }

  private func showPhysicalCardActivationByCode() {
    analyticsManager?.track(event: Event.manageCardActivatePhysicalCardOverlay)
    UIAlertController.prompt(title: "manage.shift.card.enter-code.title".podLocalized(),
                             message: "manage.shift.card.enter-code.message".podLocalized(),
                             placeholder: "manage.shift.card.enter-code.placeholder".podLocalized(),
                             keyboardType: .numberPad,
                             textFieldDelegate: cardActivationTextFieldDelegate,
                             okTitle: "manage.shift.card.enter-code.submit".podLocalized(),
                             cancelTitle: "general.button.cancel".podLocalized()) { [unowned self] code in
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
