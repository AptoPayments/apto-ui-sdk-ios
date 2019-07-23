//
//  PhysicalCardActivationSucceedContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 19/10/2018.
//

import AptoSDK
import Bond

typealias PhysicalCardActivationSucceedViewControllerProtocol = ShiftViewController

class PhysicalCardActivationSucceedViewModel {
  let showGetPinButton: Observable<Bool> = Observable(false)
  let showChargeLabel: Observable<Bool> = Observable(false)
}

protocol PhysicalCardActivationSucceedPresenterProtocol: class {
  var viewModel: PhysicalCardActivationSucceedViewModel { get }
  // swiftlint:disable implicitly_unwrapped_optional
  var interactor: PhysicalCardActivationSucceedInteractorProtocol! { get set }
  var router: PhysicalCardActivationSucceedRouter! { get set }
  var analyticsManager: AnalyticsServiceProtocol? { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  func viewLoaded()
  func getPinTapped()
  func closeTapped()
}

protocol PhysicalCardActivationSucceedInteractorProtocol {
  func provideCard(callback: (_ card: Card) -> Void)
}

protocol PhysicalCardActivationSucceedRouter: class {
  func call(url: URL, completion: @escaping () -> Void)
  func showSetPin()
  func showVoIP()
  func getPinFinished()
  func close()
}

protocol PhysicalCardActivationSucceedModuleProtocol: UIModuleProtocol, PhysicalCardActivationSucceedRouter {
}
