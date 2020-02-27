//
//  CreatePasscodeModuleTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
@testable import AptoUISDK

class CreatePasscodeModuleSpy: UIModuleSpy, CreatePasscodeModuleProtocol {
  private(set) var showURLCalled = false
  private(set) var lastShowURL: TappedURL?
  func show(url: TappedURL) {
    showURLCalled = true
    lastShowURL = url
  }
}

class CreatePasscodeInteractorSpy: CreatePasscodeInteractorProtocol {
  private(set) var saveCodeCalled = false
  private(set) var lastSaveCode: String?
  func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    saveCodeCalled = true
    lastSaveCode = code
  }
}

class CreatePasscodeInteractorFake: CreatePasscodeInteractorSpy {
  var nextSaveCodeResult: Result<Void, NSError>?
  override func save(code: String, callback: @escaping Result<Void, NSError>.Callback) {
    super.save(code: code, callback: callback)
    if let result = nextSaveCodeResult {
      callback(result)
    }
  }
}

class CreatePasscodePresenterSpy: CreatePasscodePresenterProtocol {
  let viewModel = CreatePasscodeViewModel()
  var interactor: CreatePasscodeInteractorProtocol?
  var router: CreatePasscodeModuleProtocol?
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
