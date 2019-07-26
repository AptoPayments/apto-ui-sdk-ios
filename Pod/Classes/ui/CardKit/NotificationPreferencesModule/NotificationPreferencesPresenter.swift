//
//  NotificationPreferencesPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/03/2019.
//

import AptoSDK
import Bond

class NotificationPreferencesPresenter: NotificationPreferencesPresenterProtocol {
  let viewModel = NotificationPreferencesViewModel()
  weak var router: NotificationPreferencesModuleProtocol?
  var interactor: NotificationPreferencesInteractorProtocol?
  var analyticsManager: AnalyticsServiceProtocol?
  var preferences: NotificationPreferences?

  func viewLoaded() {
    router?.showLoadingView()
    interactor?.fetchPreferences { [weak self] result in
      guard let self = self else { return }
      self.router?.hideLoadingView()
      switch result {
      case .failure(let error):
        self.router?.show(error: error)
      case .success(let preferences):
        self.preferences = preferences
        self.updateViewModel(with: preferences)
        break
      }
    }
    analyticsManager?.track(event: Event.accountSettingsNotificationPreferences)
  }

  func closeTapped() {
    router?.close()
  }

  func didUpdateNotificationRow(_ row: NotificationRow) {
    guard let preferences = self.preferences, let channel1 = viewModel.channel1.value,
          let channel2 = viewModel.channel2.value else {
      return
    }
    for notificationGroup in preferences.preferences {
      if notificationGroup.groupId.rawValue == row.id {
        notificationGroup[channel1] = row.isChannel1Active
        notificationGroup[channel2] = row.isChannel2Active
        break
      }
    }
    let enabledGroups = preferences.preferences.filter { $0.state == .enabled }
    interactor?.updatePreferences(NotificationPreferences(preferences: enabledGroups)) { [weak self] result in
      switch result {
      case .failure(let error):
        self?.router?.show(error: error)
      case .success(let preferences):
        self?.updateViewModel(with: preferences)
      }
    }
  }

  private func updateViewModel(with preferences: NotificationPreferences) {
    guard let firstGroup = preferences.preferences.first else { return }
    let channel1: NotificationChannel = .push // We assume push is always enabled
    let channel2: NotificationChannel = firstGroup.channel.email != nil ? .email : .sms
    var categories = [NotificationCategory]()
    var currentCategory: NotificationGroup.Category?
    var currentRows = [NotificationRow]()
    for notificationGroup in preferences.preferences {
      if let category = currentCategory, notificationGroup.category != category, !currentRows.isEmpty {
        categories.append(NotificationCategory(title: category.title, description: category.description,
                                               rows: currentRows))
        currentRows = []
      }
      if let value1 = notificationGroup[channel1], let value2 = notificationGroup[channel2] {
        currentRows.append(NotificationRow(id: notificationGroup.groupId.rawValue,
                                           title: notificationGroup.groupId.description,
                                           isChannel1Active: value1, isChannel2Active: value2,
                                           isEnabled: notificationGroup.state == .enabled))
      }
      currentCategory = notificationGroup.category
    }
    if let currentCategory = currentCategory, !currentRows.isEmpty {
      categories.append(NotificationCategory(title: currentCategory.title, description: currentCategory.description,
                                             rows: currentRows))
    }
    viewModel.channel1.send(channel1)
    viewModel.channel2.send(channel2)
    viewModel.categories.send(categories)
  }
}

private extension NotificationGroup {
  subscript(index: NotificationChannel) -> Bool? {
    get {
      switch index {
      case .push:
        return self.channel.push
      case .email:
        return self.channel.email
      case .sms:
        return self.channel.sms
      }
    }
    set(newValue) {
      switch index {
      case .push:
        self.channel.push = newValue
      case .email:
        return self.channel.email = newValue
      case .sms:
        return self.channel.sms = newValue
      }
    }
  }
}
