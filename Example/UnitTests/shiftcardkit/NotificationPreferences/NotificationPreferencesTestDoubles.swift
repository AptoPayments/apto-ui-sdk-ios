//
// NotificationPreferencesTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/03/2019.
//

import AptoSDK
@testable import AptoUISDK

class NotificationPreferencesModuleSpy: UIModuleSpy, NotificationPreferencesModuleProtocol {
}

class NotificationPreferencesInteractorSpy: NotificationPreferencesInteractorProtocol {
  private(set) var fetchPreferencesCalled = false
  func fetchPreferences(completion: @escaping Result<NotificationPreferences, NSError>.Callback) {
    fetchPreferencesCalled = true
  }

  private(set) var updatePreferencesCalled = false
  private(set) var lastPreferencesToUpdate: NotificationPreferences?
  func updatePreferences(_ preferences: NotificationPreferences,
                         completion: @escaping Result<NotificationPreferences, NSError>.Callback) {
    updatePreferencesCalled = true
    lastPreferencesToUpdate = preferences
  }
}

class NotificationPreferencesInteractorFake: NotificationPreferencesInteractorSpy {
  var nextFetchPreferencesResult: Result<NotificationPreferences, NSError>?
  override func fetchPreferences(completion: @escaping Result<NotificationPreferences, NSError>.Callback) {
    super.fetchPreferences(completion: completion)

    if let result = nextFetchPreferencesResult {
      completion(result)
    }
  }

  var nextUpdatePreferencesResult: Result<NotificationPreferences, NSError>?
  override func updatePreferences(_ preferences: NotificationPreferences,
                                  completion: @escaping Result<NotificationPreferences, NSError>.Callback) {
    super.updatePreferences(preferences, completion: completion)

    if let result = nextUpdatePreferencesResult {
      completion(result)
    }
  }
}

class NotificationPreferencesPresenterSpy: NotificationPreferencesPresenterProtocol {
  var router: NotificationPreferencesModuleProtocol?
  var interactor: NotificationPreferencesInteractorProtocol?
  let viewModel = NotificationPreferencesViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var didUpdateNotificationRowCalled = false
  private(set) var lastRowUpdated: NotificationRow?
  func didUpdateNotificationRow(_ row: NotificationRow) {
    didUpdateNotificationRowCalled = true
    lastRowUpdated = row
  }
}
