//
//  PhysicalCardActivationSucceedPresenter.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import Foundation
import AptoSDK

class PhysicalCardActivationSucceedPresenter: PhysicalCardActivationSucceedPresenterProtocol {
  let viewModel = PhysicalCardActivationSucceedViewModel()
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: PhysicalCardActivationSucceedInteractorProtocol!
  weak var router: PhysicalCardActivationSucceedRouter!
  // swiftlint:enable implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol?
  private var actionType: ActionType?

  func viewLoaded() {
    analyticsManager?.track(event: Event.manageCardActivatePhysicalCard)
    interactor.provideCard { [unowned self] card in
      let type = actionType(for: card)
      self.actionType = type
      switch type {
      case .changePin:
        self.viewModel.showGetPinButton.next(true)
        self.viewModel.showChargeLabel.next(false)
      case .ivr, .voIP:
        self.viewModel.showGetPinButton.next(true)
        self.viewModel.showChargeLabel.next(true)
      case .disabled:
        self.viewModel.showGetPinButton.next(false)
        self.viewModel.showChargeLabel.next(false)
      }
    }
  }

  func getPinTapped() {
    guard let actionType = self.actionType else { return }
    switch actionType {
    case .changePin:
      router.showSetPin()
    case .ivr(let phoneNumber):
      if let url = PhoneHelper.sharedHelper().callURL(from: phoneNumber) {
        router.call(url: url) { [unowned self] in
          self.router.getPinFinished()
        }
      }
    case .voIP:
      router.showVoIP()
    case .disabled:
      router.getPinFinished()
    }
  }

  func closeTapped() {
    if viewModel.showGetPinButton.value {
      router.close()
    }
    else {
      // If there is no get pin button closing trigger the finish flow
      router.getPinFinished()
    }
  }
}

private extension PhysicalCardActivationSucceedPresenter {
  enum ActionType {
    case disabled
    case changePin
    case ivr(phoneNumber: PhoneNumber)
    case voIP
  }

  func actionType(for card: Card) -> ActionType {
    if let setPinAction = card.features?.setPin, setPinAction.status != .disabled {
      switch setPinAction.source {
      case .api:
        return .changePin
      case .voIP:
        return .voIP
      case .ivr(let ivr):
        return .ivr(phoneNumber: ivr.phone)
      case .unknown:
        return .disabled
      }
    }
    if let getPinAction = card.features?.getPin, getPinAction.status != .disabled {
      switch getPinAction.source {
      case .api:
        // Get PIN via API is not available yet
        return .disabled
      case .voIP:
        return .voIP
      case .ivr(let ivr):
        return .ivr(phoneNumber: ivr.phone)
      case .unknown:
        break
      }
    }
    return .disabled
  }
}
