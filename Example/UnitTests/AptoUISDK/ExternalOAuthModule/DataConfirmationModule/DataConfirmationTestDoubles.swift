//
//  DataConfirmationTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//
//

@testable import AptoSDK
@testable import AptoUISDK

class DataConfirmationModuleSpy: UIModuleSpy, DataConfirmationModuleProtocol {
  var delegate: DataConfirmationModuleDelegate?

  private(set) var confirmDataCalled = false
  func confirmData() {
    confirmDataCalled = true
  }

  private(set) var showURLCalled = false
  func show(url: URL) {
    showURLCalled = true
  }

  private(set) var reloadUserDataCalled = false
  func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback) {
    reloadUserDataCalled = true
  }

  private(set) var updateUserDataCalled = false
  private(set) var lastUserDataToUpdateTo: DataPointList?
  func updateUserData(_ userData: DataPointList) {
    updateUserDataCalled = true
    lastUserDataToUpdateTo = userData
  }
}

class DataConfirmationModuleFake: DataConfirmationModuleSpy {
  var nextReloadUserDataResult: Result<DataPointList, NSError>?
  override func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback) {
    super.reloadUserData(callback: callback)

    if let result = nextReloadUserDataResult {
      callback(result)
    }
  }
}

class DataConfirmationModuleDelegateSpy: DataConfirmationModuleDelegate {
  private(set) var reloadUserDataCalled = false
  func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback) {
    reloadUserDataCalled = true
  }
}

class DataConfirmationModuleDelegateFake: DataConfirmationModuleDelegateSpy {
  var nextReloadUserDataResult: Result<DataPointList, NSError>?
  override func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback) {
    super.reloadUserData(callback: callback)

    if let result = nextReloadUserDataResult {
      callback(result)
    }
  }
}

class DataConfirmationPresenterSpy: DataConfirmationPresenterProtocol {
  let viewModel = DataConfirmationViewModel()
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: DataConfirmationInteractorProtocol!
  var router: DataConfirmationRouter!
  // swiftlint:enable implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol?
  
  private(set) var viewLoadedCalled = false
  func viewLoaded() {
    viewLoadedCalled = true
  }

  private(set) var confirmDataTappedCalled = false
  func confirmDataTapped() {
    confirmDataTappedCalled = true
  }

  private(set) var closeTappedCalled = false
  func closeTapped() {
    closeTappedCalled = true
  }

  private(set) var showURLCalled = false
  func show(url: URL) {
    showURLCalled = true
  }

  private(set) var reloadTappedCalled = false
  func reloadTapped() {
    reloadTappedCalled = true
  }

  private(set) var updateUserDataCalled = false
  private(set) var lastUserDataToUpdateTo: DataPointList?
  func updateUserData(_ userData: DataPointList) {
    updateUserDataCalled = true
    lastUserDataToUpdateTo = userData
  }
}

class DataConfirmationInteractorSpy: DataConfirmationInteractorProtocol {
  private(set) var provideUserDataCalled = false
  func provideUserData(completion: (_ userData: DataPointList) -> Void) {
    provideUserDataCalled = true
  }
}

class DataConfirmationInteractorFake: DataConfirmationInteractorSpy {
  var nextUserData: DataPointList?
  override func provideUserData(completion: (_ userData: DataPointList) -> Void) {
    super.provideUserData(completion: completion)

    if let nextUserData = nextUserData {
      completion(nextUserData)
    }
  }
}
