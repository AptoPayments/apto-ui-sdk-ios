//
// SetCodeTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 14/06/2019.
//

import AptoSDK
@testable import AptoUISDK

class SetCodeModuleSpy: UIModuleSpy, SetCodeModuleProtocol {
  private(set) var codeChangedCalled = false
  func codeChanged() {
    codeChangedCalled = true
  }
}

class SetCodeInteractorSpy: SetCodeInteractorProtocol {
  private(set) var changeCodeCalled = false
  private(set) var lastChangeCodeCode: String?
  func changeCode(_ code: String, completion: @escaping Result<Card, NSError>.Callback) {
    changeCodeCalled = true
    lastChangeCodeCode = code
  }
}

class SetCodeInteractorFake: SetCodeInteractorSpy {
  var nextChangeCodeResult: Result<Card, NSError>?
  override func changeCode(_ code: String, completion: @escaping Result<Card, NSError>.Callback) {
    super.changeCode(code, completion: completion)

    if let result = nextChangeCodeResult {
      completion(result)
    }
  }
}

class SetCodePresenterSpy: SetCodePresenterProtocol {
  let viewModel = SetCodeViewModel()
  var interactor: SetCodeInteractorProtocol?
  var router: SetCodeModuleProtocol?
  var analyticsManager: AnalyticsServiceProtocol?

  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var codeEnteredCalled = false
  private(set) var lastCodeEntered: String?
  func codeEntered(_ code: String) {
    codeEnteredCalled = true
    lastCodeEntered = code
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }
}
