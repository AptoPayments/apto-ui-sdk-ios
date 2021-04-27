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
  func showCardInfo()
  func hideCardInfo()
  func cardStateChanged(includingTransactions: Bool)
}

protocol CardSettingsRouterProtocol: class {
  func closeFromShiftCardSettings()
  func changeCardPin()
  func setPassCode()
  func showVoIP(actionSource: VoIPActionSource)
  func call(url: URL, completion: @escaping () -> Void)
  func showCardInfo()
  func hideCardInfo()
  func cardStateChanged(includingTransactions: Bool)
  func show(content: Content, title: String)
  func showMonthlyStatements()
  func authenticate(completion: @escaping (Bool) -> Void)
  func showAddFunds(for card: Card, extraContent: ExtraContent?)
    func showACHAccountAgreements(disclaimer: Content,
                                   cardId: String,
                                   acceptCompletion: @escaping () -> Void,
                                   declineCompletion: @escaping () -> Void)
    func showAddMoneyBottomSheet(card: Card, extraContent: ExtraContent?)
    func showOrderPhysicalCard(_ card: Card, completion: OrderPhysicalCardUIComposer.OrderedCompletion?)
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

struct LegalDocuments {
    let cardHolderAgreement: Content?
    let faq: Content?
    let termsAndConditions: Content?
    let privacyPolicy: Content?
    let exchangeRates: Content?
}

extension LegalDocuments {
    init() {
        self.init(cardHolderAgreement: nil, faq: nil, termsAndConditions: nil, privacyPolicy: nil, exchangeRates: nil)
    }
}

struct CardSettingsButtonsVisibility {
  let showChangePin: Bool
  let showGetPin: Bool
  let showSetPassCode: Bool
  let showIVRSupport: Bool
  let showDetailedCardActivity: Bool
  let isShowDetailedCardActivityEnabled: Bool
  let showMonthlyStatements: Bool
  let showAddFundsFeature: Bool
    let showOrderPhysicalCard: Bool
}

extension CardSettingsButtonsVisibility {
  init() {
    self.init(showChangePin: false, showGetPin: false, showSetPassCode: false, showIVRSupport: false,
              showDetailedCardActivity: false, isShowDetailedCardActivityEnabled: false, showMonthlyStatements: false,
              showAddFundsFeature: false, showOrderPhysicalCard: false)
  }
}

class CardSettingsViewModel {
  let locked: Observable<Bool?> = Observable(nil)
  let legalDocuments: Observable<LegalDocuments> = Observable(LegalDocuments())
  let buttonsVisibility: Observable<CardSettingsButtonsVisibility> = Observable(CardSettingsButtonsVisibility())
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
  func setPassCodeTapped()
  func callIvrTapped()
  func lockCardChanged(switcher: UISwitch)
  func didTapOnShowCardInfo()
  func show(content: Content, title: String)
  func updateCardNewStatus()
  func showDetailedCardActivity(_ newValue: Bool)
  func monthlyStatementsTapped()
  func didTapOnLoadFunds()
    func didTapOnOrderPhysicalCard()
}

public struct ExtraContent {
    public let content: Content?
    public let title: String
}
