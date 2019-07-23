//
//  VoIPModuleContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 18/06/2019.
//

import AptoSDK
import Bond

protocol VoIPModuleProtocol: UIModuleProtocol {
  func callFinished()
}

protocol VoIPInteractorProtocol {
  func fetchVoIPToken(callback: @escaping Result<VoIPToken, NSError>.Callback)
}

enum CallState: Equatable {
  case starting
  case established
  case finished
}

class VoIPViewModel {
  let callState: Observable<CallState?> = Observable(nil)
  let timeElapsed: Observable<String?> = Observable(nil)
  let error: Observable<NSError?> = Observable(nil)
}

protocol VoIPPresenterProtocol: class {
  var router: VoIPModuleProtocol? { get set }
  var interactor: VoIPInteractorProtocol? { get set }
  var viewModel: VoIPViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func muteCallTapped()
  func unmuteCallTapped()
  func hangupCallTapped()
  func keyboardDigitTapped(_ digit: String)
}
