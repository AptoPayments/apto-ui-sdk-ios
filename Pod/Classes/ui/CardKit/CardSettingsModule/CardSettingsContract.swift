//
//  CardSettingsContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/08/2018.
//
//

import Bond
import AptoSDK

protocol CardSettingsModuleDelegate: class {
  func showCardInfo(completion: @escaping () -> Void)
  func hideCardInfo()
  func isCardInfoVisible() -> Bool
  func cardStateChanged(includingTransactions: Bool)
}

protocol CardSettingsRouterProtocol: class {
  func closeFromShiftCardSettings()
  func changeCardPin()
  func showVoIP(actionSource: VoIPActionSource)
  func call(url: URL, completion: @escaping () -> Void)
  func showCardInfo(completion: @escaping () -> Void)
  func hideCardInfo()
  func isCardInfoVisible() -> Bool
  func cardStateChanged(includingTransactions: Bool)
  func show(content: Content, title: String)
}

extension CardSettingsRouterProtocol {
  func cardStateChanged(includingTransactions: Bool = false) {
    cardStateChanged(includingTransactions: includingTransactions)
  }
}

protocol CardSettingsModuleProtocol: UIModuleProtocol {
  var delegate: CardSettingsModuleDelegate? { get set }
}

protocol CardSettingsViewProtocol: ViewControllerProtocol {
  func showLoadingSpinner()
  func show(error: Error)
  func showClosedCardErrorAlert(title: String)
}

typealias CardSettingsViewControllerProtocol = ShiftViewController & CardSettingsViewProtocol

protocol CardSettingsInteractorProtocol {
  func isShowDetailedCardActivityEnabled() -> Bool
  func setShowDetailedCardActivityEnabled(_ isEnabled: Bool)
}

public struct LegalDocuments {
  public let cardHolderAgreement: Content?
  public let faq: Content?
  public let termsAndConditions: Content?
  public let privacyPolicy: Content?
}

extension LegalDocuments {
  init() {
    self.init(cardHolderAgreement: nil, faq: nil, termsAndConditions: nil, privacyPolicy: nil)
  }
}

open class CardSettingsViewModel {
  public let locked: Observable<Bool?> = Observable(nil)
  public let showCardInfo: Observable<Bool?> = Observable(nil)
  public let legalDocuments: Observable<LegalDocuments> = Observable(LegalDocuments())
  public let showChangePin: Observable<Bool> = Observable(false)
  public let showGetPin: Observable<Bool> = Observable(false)
  public let showIVRSupport: Observable<Bool> = Observable(false)
  public let showDetailedCardActivity: Observable<Bool> = Observable(false)
  public let isShowDetailedCardActivityEnabled: Observable<Bool> = Observable(false)
}

protocol CardSettingsPresenterProtocol: class {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: CardSettingsViewProtocol! { get set }
  var interactor: CardSettingsInteractorProtocol! { get set }
  var router: CardSettingsRouterProtocol! { get set }
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: CardSettingsViewModel { get }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func helpTapped()
  func lostCardTapped()
  func changePinTapped()
  func getPinTapped()
  func callIvrTapped()
  func lockCardChanged(switcher: UISwitch)
  func showCardInfoChanged(switcher: UISwitch)
  func show(content: Content, title: String)
  func updateCardNewStatus()
  func showDetailedCardActivity(_ newValue: Bool)
}
