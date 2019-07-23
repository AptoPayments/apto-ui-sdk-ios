//
// SetPinTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/06/2019.
//

import AptoSDK
@testable import AptoUISDK

class SetPinModuleSpy: UIModuleSpy, SetPinModuleProtocol {
  private(set) var pinChangedCalled = false
  func pinChanged() {
    pinChangedCalled = true
  }
}

class SetPinInteractorSpy: SetPinInteractorProtocol {
  private(set) var changePinCalled = false
  private(set) var lastPinToChange: String?
  func changePin(_ pin: String, completion: @escaping Result<Card, NSError>.Callback) {
    changePinCalled = true
    lastPinToChange = pin
  }
}

class SetPinInteractorFake: SetPinInteractorSpy {
  var nextChangePinResult: Result<Card, NSError>?
  override func changePin(_ pin: String, completion: @escaping Result<Card, NSError>.Callback) {
    super.changePin(pin, completion: completion)

    if let result = nextChangePinResult {
      completion(result)
    }
  }
}

class SetPinPresenterSpy: SetPinPresenterProtocol {
  let viewModel = SetPinViewModel()
  var interactor: SetPinInteractorProtocol?
  var router: SetPinModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var pinEnteredCalled = false
  private(set) var lastPinEntered: String?
  func pinEntered(_ pin: String) {
    pinEnteredCalled = true
    lastPinEntered = pin
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }
}
