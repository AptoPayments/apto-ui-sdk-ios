//
//  WaitListPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 27/02/2019.
//

import AptoSDK
import Bond

class WaitListPresenter: CardApplicationWaitListPresenterProtocol {
  private let notificationHandler: NotificationHandler
  private let config: WaitListActionConfiguration?
  let viewModel = WaitListViewModel()
  var interactor: WaitListInteractorProtocol?
  weak var router: WaitListModuleProtocol?
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
    analyticsManager?.track(event: Event.workflowWaitlist)
  }

  @objc private func backgroundRefresh() {
    interactor?.reloadApplication { [weak self] result in
      guard let self = self else { return }
      if result.isSuccess, let application = result.value {
        if application.nextAction.actionType != .waitList {
          self.notificationHandler.removeObserver(self)
          self.router?.applicationStatusChanged()
        }
      }
    }
  }
}
