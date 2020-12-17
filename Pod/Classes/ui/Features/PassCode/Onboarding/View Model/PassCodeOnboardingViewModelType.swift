import Bond
import AptoSDK
import UIKit

enum PassCodeOnboardingViewState {
  case idle
  case loading
  case loaded(Verification?)
  case error(Error)
}

enum PassCodeModuleState {
  case idle
  case finished
}

protocol PassCodeOnboardingViewModelType {
  var input: PassCodeOnboardingViewModelInput { get }
  var output: PassCodeOnboardingViewModelOutput { get }
}

protocol PassCodeOnboardingViewModelInput {
  func didTapOnSetPassCode()
}

protocol PassCodeOnboardingViewModelOutput {
  var state: Observable<PassCodeOnboardingViewState> { get }
  var moduleState: Observable<PassCodeModuleState> { get }
  var nextButtonEnabled: Observable<Bool> { get }
}
