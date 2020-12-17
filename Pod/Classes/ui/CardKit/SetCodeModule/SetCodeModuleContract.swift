import AptoSDK
import Bond

protocol SetCodeModuleProtocol: UIModuleProtocol {
  func codeChanged()
}

protocol SetCodeInteractorProtocol {
  func changeCode(_ code: String, completion: @escaping Result<Card, NSError>.Callback)
}

public struct SetCodeViewControllerTexts {
  struct SetCode {
    let title: String
    let explanation: String
    let wrongCodeTitle: String
    let wrongCodeMessage: String
  }
  struct ConfirmCode {
    let title: String
    let explanation: String
  }
  let setCode: SetCode
  let confirmCode: ConfirmCode
}

class SetCodeViewModel {
  let showLoading: Observable<Bool?> = Observable(nil)
  let error: Observable<Error?> = Observable(nil)
}

protocol SetCodePresenterProtocol: class {
  var router: SetCodeModuleProtocol? { get set }
  var interactor: SetCodeInteractorProtocol? { get set }
  var viewModel: SetCodeViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func codeEntered(_ code: String)
  func closeTapped()
}
