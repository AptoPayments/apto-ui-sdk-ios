//
//  DataConfirmationContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

import AptoSDK
import Bond

protocol DataConfirmationRouter: class {
  func confirmData()
  func close()
  func show(url: URL)
  func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback)
}

protocol DataConfirmationModuleDelegate {
  func reloadUserData(callback: @escaping Result<DataPointList, NSError>.Callback)
}

protocol DataConfirmationModuleProtocol: UIModuleProtocol, DataConfirmationRouter {
  var delegate: DataConfirmationModuleDelegate? { get set }

  func updateUserData(_ userData: DataPointList)
}

class DataConfirmationViewModel {
  let userData: Observable<DataPointList?> = Observable(nil)
  let error: Observable<Error?> = Observable(nil)
}

protocol DataConfirmationPresenterProtocol: class {
  var viewModel: DataConfirmationViewModel { get }
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: DataConfirmationInteractorProtocol! { get set }
  var router: DataConfirmationRouter! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func confirmDataTapped()
  func closeTapped()
  func show(url: URL)
  func reloadTapped()
  func updateUserData(_ userData: DataPointList)
}

protocol DataConfirmationInteractorProtocol {
  func provideUserData(completion: (_ userData: DataPointList) -> Void)
}
