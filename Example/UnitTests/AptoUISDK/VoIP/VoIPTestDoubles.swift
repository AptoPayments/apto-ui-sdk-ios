//
// VoIPTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/06/2019.
//

import AptoSDK
@testable import AptoUISDK

class VoIPModuleSpy: UIModuleSpy, VoIPModuleProtocol {
  private(set) var callFinishedCalled = false
  func callFinished() {
    callFinishedCalled = true
  }
}

class VoIPInteractorSpy: VoIPInteractorProtocol {
  private(set) var fetchVoIPTokenCalled = false
  func fetchVoIPToken(callback: @escaping Result<VoIPToken, NSError>.Callback) {
    fetchVoIPTokenCalled = true
  }
}

class VoIPInteractorFake: VoIPInteractorSpy {
  var nextFetchVoIPTokenResult: Result<VoIPToken, NSError>?
  override func fetchVoIPToken(callback: @escaping Result<VoIPToken, NSError>.Callback) {
    super.fetchVoIPToken(callback: callback)

    if let result = nextFetchVoIPTokenResult {
      callback(result)
    }
  }
}

class VoIPPresenterSpy: VoIPPresenterProtocol {
  let viewModel = VoIPViewModel()
  var interactor: VoIPInteractorProtocol?
  var router: VoIPModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var muteCallTappedCalled = false
  func muteCallTapped() {
    muteCallTappedCalled = true
  }

  private(set) var unmuteCallTappedCalled = false
  func unmuteCallTapped() {
    unmuteCallTappedCalled = true
  }

  private(set) var hangupCallTappedCalled = false
  func hangupCallTapped() {
    hangupCallTappedCalled = true
  }

  private(set) var keyboardDigitTappedCalled = false
  private(set) var lastKeyboardDigitTapped: String?
  func keyboardDigitTapped(_ digit: String) {
    keyboardDigitTappedCalled = true
    lastKeyboardDigitTapped = digit
  }
}
