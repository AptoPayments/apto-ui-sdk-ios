//
// CardWaitListPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import Foundation
import AptoSDK

class CardWaitListPresenter: CardWaitListPresenterProtocol {
  private let config: WaitListActionConfiguration?
  let viewModel = WaitListViewModel()
  var interactor: CardWaitListInteractorProtocol?
  weak var router: CardWaitListModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: WaitListActionConfiguration?) {
    self.config = config
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(backgroundRefresh),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func viewLoaded() {
    viewModel.asset.send(config?.asset)
    viewModel.backgroundColor.send(config?.backgroundColor)
    viewModel.backgroundImage.send(config?.backgroundImage)
    analyticsManager?.track(event: Event.waitlist)
  }

  @objc private func backgroundRefresh() {
    interactor?.reloadCard { [weak self] result in
      guard let self = self else { return }
      if result.isSuccess, let card = result.value {
        if card.isInWaitList != true {
          NotificationCenter.default.removeObserver(self)
          self.router?.cardStatusChanged()
        }
      }
    }
  }
}
