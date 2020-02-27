//
// CardWaitListPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 01/03/2019.
//

import Foundation
import AptoSDK

class CardWaitListPresenter: CardWaitListPresenterProtocol {
  private let notificationHandler: NotificationHandler
  private let config: WaitListActionConfiguration?
  let viewModel = WaitListViewModel()
  var interactor: CardWaitListInteractorProtocol?
  weak var router: CardWaitListModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  init(config: WaitListActionConfiguration?, notificationHandler: NotificationHandler) {
    self.config = config
    self.notificationHandler = notificationHandler
    notificationHandler.addObserver(self, selector: #selector(backgroundRefresh),
                                    name: UIApplication.didBecomeActiveNotification)
  }

  deinit {
    notificationHandler.removeObserver(self)
  }

  func viewLoaded() {
    viewModel.asset.send(config?.asset)
    viewModel.backgroundColor.send(config?.backgroundColor)
    viewModel.darkBackgroundColor.send(config?.darkBackgroundColor)
    viewModel.backgroundImage.send(config?.backgroundImage)
    analyticsManager?.track(event: Event.waitlist)
  }

  @objc private func backgroundRefresh() {
    interactor?.reloadCard { [weak self] result in
      guard let self = self else { return }
      if result.isSuccess, let card = result.value {
        if card.isInWaitList != true {
          self.notificationHandler.removeObserver(self)
          self.router?.cardStatusChanged()
        }
      }
    }
  }
}
