//
//  CreatePINModuleModuleContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
import Bond

protocol CreatePINModuleProtocol: UIModuleProtocol {
  func show(url: TappedURL)
}

protocol CreatePINInteractorProtocol {
  func save(code: String, callback: @escaping Result<Void, NSError>.Callback)
}

class CreatePINViewModel {
  let error: Observable<NSError?> = Observable(nil)
}

protocol CreatePINPresenterProtocol: class {
  var router: CreatePINModuleProtocol? { get set }
  var interactor: CreatePINInteractorProtocol? { get set }
  var viewModel: CreatePINViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func pinEntered(_ code: String)
  func show(url: TappedURL)
}
