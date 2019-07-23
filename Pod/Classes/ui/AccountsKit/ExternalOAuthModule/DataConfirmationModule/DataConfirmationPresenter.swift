//
//  DataConfirmationPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

import AptoSDK

class DataConfirmationPresenter: DataConfirmationPresenterProtocol {
  let viewModel = DataConfirmationViewModel()
  var interactor: DataConfirmationInteractorProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
  weak var router: DataConfirmationRouter! // swiftlint:disable:this implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol?

  func viewLoaded() {
    interactor.provideUserData { [unowned self] userData in
      self.viewModel.userData.next(userData)
    }
    analyticsManager?.track(event: Event.selectBalanceStoreOauthConfirm)
  }

  func confirmDataTapped() {
    router.confirmData()
    analyticsManager?.track(event: Event.selectBalanceStoreOauthConfirmTap)
  }

  func closeTapped() {
    router.close()
    analyticsManager?.track(event: Event.selectBalanceStoreOauthConfirmConfirmBackTap)
  }

  func show(url: URL) {
    router.show(url: url)
  }

  func reloadTapped() {
    analyticsManager?.track(event: Event.selectBalanceStoreOauthConfirmRefreshDetailsTap)
    router.reloadUserData { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.viewModel.error.next(error)
      case .success(let userData):
        self.viewModel.userData.next(userData)
      }
    }
  }

  func updateUserData(_ userData: DataPointList) {
    viewModel.userData.next(userData)
  }
}
