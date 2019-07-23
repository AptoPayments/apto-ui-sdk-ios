//
// WaitListTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 27/02/2019.
//

import AptoSDK
@testable import AptoUISDK

class WaitListModuleSpy: UIModuleSpy, WaitListModuleProtocol {
  private(set) var applicationStatusChangedCalled = false
  func applicationStatusChanged() {
    applicationStatusChangedCalled = true
  }
}

class WaitListInteractorSpy: WaitListInteractorProtocol {
  private(set) var reloadApplicationCalled = false
  func reloadApplication(completion: @escaping Result<CardApplication, NSError>.Callback) {
    reloadApplicationCalled = true
  }
}

class WaitListInteractorFake: WaitListInteractorSpy {
  var nextReloadApplicationResult: Result<CardApplication, NSError>?
  override func reloadApplication(completion: @escaping Result<CardApplication, NSError>.Callback) {
    super.reloadApplication(completion: completion)

    if let result = nextReloadApplicationResult {
      completion(result)
    }
  }
}

class WaitListPresenterSpy: CardApplicationWaitListPresenterProtocol {
  let viewModel = WaitListViewModel()
  var interactor: WaitListInteractorProtocol?
  var router: WaitListModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?
  
  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }
}

class CardWaitListModuleSpy: UIModuleSpy, CardWaitListModuleProtocol {
  private(set) var cardStatusChangedCalled = false
  func cardStatusChanged() {
    cardStatusChangedCalled = true
  }
}

class CardWaitListInteractorSpy: CardWaitListInteractorProtocol {
  private(set) var reloadCardCalled = false
  func reloadCard(completion: @escaping Result<Card, NSError>.Callback) {
    reloadCardCalled = true
  }
}

class CardWaitListInteractorFake: CardWaitListInteractorSpy {
  var nextReloadCardResult: Result<Card, NSError>?
  override func reloadCard(completion: @escaping Result<Card, NSError>.Callback) {
    super.reloadCard(completion: completion)

    if let result = nextReloadCardResult {
      completion(result)
    }
  }
}

class CardWaitListPresenterSpy: CardWaitListPresenterProtocol {
  let viewModel = WaitListViewModel()
  var interactor: CardWaitListInteractorProtocol?
  var router: CardWaitListModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?
  
  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }
}
