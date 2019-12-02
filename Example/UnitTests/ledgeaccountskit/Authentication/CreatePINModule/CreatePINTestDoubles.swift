//
//  CreatePINModuleTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
@testable import AptoUISDK

class CreatePINModuleSpy: UIModuleSpy, CreatePINModuleProtocol {
  private(set) var showURLCalled = false
  private(set) var lastShowURL: TappedURL?
  func show(url: TappedURL) {
    showURLCalled = true
    lastShowURL = url
  }
}

class CreatePINInteractorSpy: CreatePINInteractorProtocol {
  private(set) var saveCodeCalled = false
  private(set) var lastSaveCode: String?
  func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    saveCodeCalled = true
    lastSaveCode = code
  }
}

class CreatePINInteractorFake: CreatePINInteractorSpy {
  var nextSaveCodeResult: Result<Void, NSError>?
  override func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    super.save(code: code, callback: callback)
    if let result = nextSaveCodeResult {
      callback(result)
    }
  }
}

class CreatePINPresenterSpy: CreatePINPresenterProtocol {
  let viewModel = CreatePINViewModel()
  var interactor: CreatePINInteractorProtocol?
  var router: CreatePINModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var pinEnteredCalled = false
  private(set) var lastPinEnteredCode: String?
  func pinEntered(_ code: String) {
    pinEnteredCalled = true
    lastPinEnteredCode = code
  }

  private(set) var showURLCalled = false
  private(set) var lastShowURL: TappedURL?
  func show(url: TappedURL) {
    showURLCalled = true
    lastShowURL = url
  }
}
