//
//  CreatePasscodeModuleModuleContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
import Bond

protocol CreatePasscodeModuleProtocol: UIModuleProtocol {
  func show(url: TappedURL)
}

protocol CreatePasscodeInteractorProtocol {
  func save(code: String, callback: @escaping Result<Void, NSError>.Callback)
}

class CreatePasscodeViewModel {
  let error: Observable<NSError?> = Observable(nil)
}

protocol CreatePasscodePresenterProtocol: class {
  var router: CreatePasscodeModuleProtocol? { get set }
  var interactor: CreatePasscodeInteractorProtocol? { get set }
  var viewModel: CreatePasscodeViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func pinEntered(_ code: String)
  func show(url: TappedURL)
}
