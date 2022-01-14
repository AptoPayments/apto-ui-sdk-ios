//
// CardSettingsTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 27/06/2019.
//

import AptoSDK
@testable import AptoUISDK

class CardSettingsModuleSpy: UIModuleSpy, CardSettingsRouterProtocol, CardSettingsModuleProtocol {
    var delegate: CardSettingsModuleDelegate?

    func showP2PTransferScreen(with _: ProjectConfiguration?) {}

    func showAddFunds(for _: Card, extraContent _: ExtraContent?) {}

    func showAddMoneyBottomSheet(card _: Card, extraContent _: ExtraContent?) {}

    func showACHAccountAgreements(disclaimer _: Content,
                                  cardId _: String,
                                  acceptCompletion _: @escaping () -> Void,
                                  declineCompletion _: @escaping () -> Void) {}

    func showOrderPhysicalCard(_: Card, completion _: OrderPhysicalCardUIComposer.OrderedCompletion?) {}

    func showApplePayIAP(cardId _: String, completion _: ApplePayIAPUIComposer.IAPCompletion?) {}

    private(set) var closeFromCardSettingsCalled = false
    func closeFromCardSettings() {
        closeFromCardSettingsCalled = true
    }

    private(set) var changeCardPinCalled = false
    func changeCardPin() {
        changeCardPinCalled = true
    }

    private(set) var setPassCodeCalled = false
    func setPassCode() {
        setPassCodeCalled = true
    }

    private(set) var showVoIPCalled = false
    private(set) var lastShowVoIPActionSource: VoIPActionSource?
    func showVoIP(actionSource: VoIPActionSource) {
        showVoIPCalled = true
        lastShowVoIPActionSource = actionSource
    }

    private(set) var callURLCalled = false
    private(set) var lastURLToCall: URL?
    func call(url: URL, completion _: @escaping () -> Void) {
        callURLCalled = true
        lastURLToCall = url
    }

    private(set) var showCardInfoCalled = false
    func showCardInfo() {
        showCardInfoCalled = true
    }

    private(set) var hideCardInfoCalled = false
    func hideCardInfo() {
        hideCardInfoCalled = true
    }

    private(set) var isCardInfoVisibleCalled = false
    func isCardInfoVisible() -> Bool {
        isCardInfoVisibleCalled = true
        return false
    }

    private(set) var cardStateChangedCalled = false
    private(set) var lastCardStateChangeIncludeTransactions: Bool?
    func cardStateChanged(includingTransactions: Bool) {
        cardStateChangedCalled = true
        lastCardStateChangeIncludeTransactions = includingTransactions
    }

    private(set) var showContentCalled = false
    private(set) var lastContentToShow: Content?
    private(set) var lastContentTitleToShow: String?
    func show(content: Content, title: String) {
        showContentCalled = true
        lastContentToShow = content
        lastContentTitleToShow = title
    }

    private(set) var showMonthlyStatementsCalled = false
    func showMonthlyStatements() {
        showMonthlyStatementsCalled = true
    }

    private(set) var authenticateCalled = false
    var nextAuthenticateResult = true
    func authenticate(completion: @escaping (Bool) -> Void) {
        authenticateCalled = true
        completion(nextAuthenticateResult)
    }
}

class CardSettingsModuleDelegateSpy: CardSettingsModuleDelegate {
    private(set) var setCardPinCalled = false
    func setCardPin() {
        setCardPinCalled = true
    }

    private(set) var showCardInfoCalled = false
    func showCardInfo() {
        showCardInfoCalled = true
    }

    private(set) var hideCardInfoCalled = false
    func hideCardInfo() {
        hideCardInfoCalled = true
    }

    private(set) var isCardInfoVisibleCalled = false
    func isCardInfoVisible() -> Bool {
        isCardInfoVisibleCalled = true
        return true
    }

    private(set) var cardStateChangedCalled = false
    private(set) var lastCardStateChangedIncludingTransactions: Bool?
    func cardStateChanged(includingTransactions: Bool) {
        cardStateChangedCalled = true
        lastCardStateChangedIncludingTransactions = includingTransactions
    }
}

class CardSettingsInteractorSpy: CardSettingsInteractorProtocol {
    private(set) var isShowDetailedCardActivityEnabledCalled = false
    func isShowDetailedCardActivityEnabled() -> Bool {
        isShowDetailedCardActivityEnabledCalled = true
        return true
    }

    private(set) var setShowDetailedCardActivityEnabledCalled = false
    private(set) var lastIsShowDetailedCardActivityEnabled: Bool?
    func setShowDetailedCardActivityEnabled(_ isEnabled: Bool) {
        setShowDetailedCardActivityEnabledCalled = true
        lastIsShowDetailedCardActivityEnabled = isEnabled
    }
}

class CardSettingsInteractorFake: CardSettingsInteractorSpy {
    var nextIsShowDetailedCardActivityEnabledResult = true
    override func isShowDetailedCardActivityEnabled() -> Bool {
        _ = super.isShowDetailedCardActivityEnabled()
        return nextIsShowDetailedCardActivityEnabledResult
    }
}

class CardSettingsPresenterSpy: CardSettingsPresenterProtocol {
    let viewModel = CardSettingsViewModel()
    // swiftlint:disable implicitly_unwrapped_optional
    var view: CardSettingsViewProtocol!
    var interactor: CardSettingsInteractorProtocol!
    var router: CardSettingsRouterProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    var analyticsManager: AnalyticsServiceProtocol?

    func didTapOnP2PTransfer() {}

    func didTapOnLoadFunds() {}

    func didTapOnOrderPhysicalCard() {}
    func didTapOnApplePayIAP() {}

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }

    private(set) var helpTappedCalled = false
    func helpTapped() {
        helpTappedCalled = true
    }

    private(set) var lostCardTappedCalled = false
    func lostCardTapped() {
        lostCardTappedCalled = true
    }

    private(set) var changePinTappedCalled = false
    func changePinTapped() {
        changePinTappedCalled = true
    }

    private(set) var getPinTappedCalled = false
    func getPinTapped() {
        getPinTappedCalled = true
    }

    private(set) var setPassCodeTappedCalled = false
    func setPassCodeTapped() {
        setPassCodeTappedCalled = true
    }

    private(set) var callIvrTappedCalled = false
    func callIvrTapped() {
        callIvrTappedCalled = true
    }

    private(set) var lockCardChangedCalled = false
    func lockCardChanged(switcher _: UISwitch) {
        lockCardChangedCalled = true
    }

    private(set) var didTapOnShowCardInfoCalled = false
    func didTapOnShowCardInfo() {
        didTapOnShowCardInfoCalled = true
    }

    private(set) var showContentCalled = false
    private(set) var lastContentToShow: Content?
    private(set) var lastContentTitleToShow: String?
    func show(content: Content, title: String) {
        showContentCalled = true
        lastContentToShow = content
        lastContentTitleToShow = title
    }

    private(set) var updateCardNewStatusCalled = false
    func updateCardNewStatus() {
        updateCardNewStatusCalled = true
    }

    private(set) var showDetailedCardActivityCalled = false
    func showDetailedCardActivity(_: Bool) {
        showDetailedCardActivityCalled = true
    }

    private(set) var monthlyStatementsTappedCalled = false
    func monthlyStatementsTapped() {
        monthlyStatementsTappedCalled = true
    }

    func cardLastFourDigits() -> String { return "1234" }
}

class CardSettingsViewSpy: ViewControllerSpy, CardSettingsViewProtocol {
    func show(error: Error) {
        super.show(error: error, uiConfig: nil)
    }

    private(set) var showClosedCardErrorAlertCalled = false
    private(set) var lastClosedCardErrorAlertTitle: String?
    func showClosedCardErrorAlert(title: String) {
        showClosedCardErrorAlertCalled = true
        lastClosedCardErrorAlertTitle = title
    }
}

class CardSettingsViewControllerDummy: AptoViewController, CardSettingsViewProtocol {
    func showClosedCardErrorAlert(title _: String) {}
}
