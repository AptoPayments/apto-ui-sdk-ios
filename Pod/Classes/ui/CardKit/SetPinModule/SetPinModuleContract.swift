//
//  SetPinModuleContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/06/2019.
//

import AptoSDK
import Bond

protocol SetPinModuleProtocol: UIModuleProtocol {
  func pinChanged()
}

protocol SetPinInteractorProtocol {
  func changePin(_ pin: String, completion: @escaping Result<Card, NSError>.Callback)
}

class SetPinViewModel {
  let showLoading: Observable<Bool?> = Observable(nil)
  let error: Observable<Error?> = Observable(nil)
}

protocol SetPinPresenterProtocol: class {
  var router: SetPinModuleProtocol? { get set }
  var interactor: SetPinInteractorProtocol? { get set }
  var viewModel: SetPinViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func pinEntered(_ pin: String)
  func closeTapped()
}
