//
//  UserDataVerificationContract.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 29/08/2018.
//

import UIKit
import Bond

protocol PINVerificationView: ViewControllerProtocol {
  func showLoadingSpinner()
  func showWrongPinError(error: Error, title: String)
  func showPinResent()
  func show(error: Error)
}

typealias PINVerificationViewControllerProtocol = AptoViewController & PINVerificationView

public enum PINEntryState {
  case enabled
  case expired
}

public enum ResendButtonState {
  case enabled
  case waiting(pendingSeconds: Int)
}

open class PINVerificationViewModel {
  public let title: Observable<String?> = Observable(nil)
  public let subtitle: Observable<String?> = Observable(nil)
  public let datapointValue: Observable<String?> = Observable(nil)
  public let footerTitle: Observable<String?> = Observable(nil)
  public let pinEntryState: Observable<PINEntryState?> = Observable(nil)
  public let resendButtonState: Observable<ResendButtonState?> = Observable(nil)
}

protocol PINVerificationPresenter: class {
  var viewModel: PINVerificationViewModel { get }
  func viewLoaded()
  func submitTapped(_ pin: String)
  func resendTapped()
  func closeTapped()
}
