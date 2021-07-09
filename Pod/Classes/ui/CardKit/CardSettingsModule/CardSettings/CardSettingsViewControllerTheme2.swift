//
// CardSettingsViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-20.
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class CardSettingsViewControllerTheme2: ShiftViewController, CardSettingsViewProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: CardSettingsPresenterProtocol
  private let titleContainerView = UIView()
  private let formView = MultiStepForm()
  private var lockCardRow: FormRowSwitchTitleSubtitleView?

  init(uiConfiguration: UIConfig, presenter: CardSettingsPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setupViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  private func set(lockedSwitch: Bool) {
    self.lockCardRow?.switcher.isOn = lockedSwitch
  }

  func showClosedCardErrorAlert(title: String) {
    let alert = UIAlertController(title: nil,
                                  message: title,
                                  preferredStyle: .alert)
    let okAction = UIAlertAction(title: "general.button.ok".podLocalized(),
                                 style: .default) { [weak self] _ in
      self?.presenter.updateCardNewStatus()
    }
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
}

extension CardSettingsViewControllerTheme2: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y < 8 {
      titleContainerView.layer.shadowOpacity = 0
    }
    else {
      if titleContainerView.layer.shadowOpacity < 1 {
        titleContainerView.layer.shadowOpacity = 1
      }
    }
  }
}

// MARK: - Set up UI
private extension CardSettingsViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpNavigationBar()
    setUpTitleView()
    setUpFormView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationSecondaryColor,
                                              tintColor: uiConfiguration.iconTertiaryColor)
    navigationController?.navigationBar.hideShadow()
    navigationItem.leftBarButtonItem?.tintColor = uiConfiguration.iconTertiaryColor
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    setNeedsStatusBarAppearanceUpdate()
  }

  func setUpTitleView() {
    titleContainerView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    titleContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    titleContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    titleContainerView.layer.shadowOpacity = 0
    titleContainerView.layer.shadowRadius = 8
    view.addSubview(titleContainerView)
    titleContainerView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
    }
    let titleLabel = ComponentCatalog.topBarTitleBigLabelWith(text: "card_settings.settings.title".podLocalized(),
                                                              textAlignment: .left,
                                                              uiConfig: uiConfiguration)
    titleContainerView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.bottom.equalToSuperview().inset(16)
    }
  }

  func setUpFormView() {
    view.addSubview(self.formView)
    formView.snp.makeConstraints { make in
      make.top.equalTo(titleContainerView.snp.bottom)
      make.left.right.bottom.equalToSuperview()
    }
    formView.backgroundColor = view.backgroundColor
    formView.delegate = self
    view.bringSubviewToFront(titleContainerView) // Make the shadow visible on scrolling
  }
}

// MARK: - View model subscriptions
private extension CardSettingsViewControllerTheme2 {
  func setupViewModelSubscriptions() { // swiftlint:disable:this function_body_length
    let viewModel = presenter.viewModel
    combineLatest(viewModel.legalDocuments, viewModel.buttonsVisibility).observeNext { [unowned self] legalDocuments,
      buttonsVisibility in
      let settingsRows = [
        self.setUpAddFundsRow(showButton: buttonsVisibility.showAddFundsFeature),
        self.createSettingsTitle(),
        self.createChangePinRow(showButton: buttonsVisibility.showChangePin),
        self.createGetPinRow(showButton: buttonsVisibility.showGetPin),
        self.createSetPassCodeRow(showButton: buttonsVisibility.showSetPassCode),
        self.setUpShowCardInfoRow(),
        self.showAppleWallet(showButton: buttonsVisibility.showAppleWalletRow),
        self.addShowOrderPhysicalCardRow(showButton: buttonsVisibility.showOrderPhysicalCard),
        self.setUpLockCardRow(),
      ].compactMap { return $0 }
      let transactionsRows = [
        self.createTransactionsTitle(showDetailedCardActivity: buttonsVisibility.showDetailedCardActivity),
        self.createDetailedCardActivityRow(showDetailedCardActivity: buttonsVisibility.showDetailedCardActivity)
      ].compactMap { return $0 }
      let helpRows = [
        self.createSupportTitle(),
        self.createIvrSupport(buttonsVisibility.showIVRSupport),
        self.createHelpButton(),
        self.createLostCardButton(),
        self.createFAQButton(legalDocuments.faq),
        self.createStatementsButton(buttonsVisibility.showMonthlyStatements)
      ].compactMap { return $0 }
      let legalRows = [
        self.createLegalTitle(legalDocuments: legalDocuments),
        self.createCardholderAgreementButton(legalDocuments.cardHolderAgreement),
        self.createTermsAndConditionsButton(legalDocuments.termsAndConditions),
        self.createPrivacyPolicyButton(legalDocuments.privacyPolicy),
        self.createExchangeRatesButton(legalDocuments.exchangeRates)
      ].compactMap { return $0 }
      var rows: [FormRowView] = [
        FormRowSeparatorView(backgroundColor: .clear, height: 16)
      ]
      if !legalRows.isEmpty {
        helpRows.last?.showSplitter = false
      }
      rows += settingsRows
      rows += transactionsRows
      rows += helpRows
      rows += legalRows
      self.formView.show(rows: rows)
    }.dispose(in: disposeBag)

    viewModel.locked.observeNext { [unowned self] locked in
      if let locked = locked {
        self.set(lockedSwitch: locked)
      }
    }.dispose(in: disposeBag)
  }

  func createSettingsTitle() -> FormRowView {
    return FormRowSectionTitleViewTheme2(title: "card_settings.settings.title".podLocalized(),
                                         uiConfig: uiConfiguration)
  }

  func createSupportTitle() -> FormRowView {
    return FormRowSectionTitleViewTheme2(title: "card_settings.help.title".podLocalized(), uiConfig: uiConfiguration)
  }

  func createIvrSupport(_ showButton: Bool) -> FormRowView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card_settings.help.ivr_support.title".podLocalized(),
                                   subtitle: "card_settings.help.ivr_support.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.callIvrTapped()
    }
  }

  func createHelpButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "card_settings.help.contact_support.title".podLocalized(),
                                   subtitle: "card_settings.help.contact_support.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.helpTapped()
    }
  }

  func createLostCardButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "card_settings.help.report_lost_card.title".podLocalized(),
                                   subtitle: "card_settings.help.report_lost_card.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.lostCardTapped()
    }
  }

  func createFAQButton(_ faq: Content?) -> FormRowView? {
    return createContentRow(faq,
                            title: "card_settings.legal.faq.title".podLocalized(),
                            subtitle: "card_settings.legal.faq.description".podLocalized())
  }

  func createStatementsButton(_ showMonthlyStatements: Bool) -> FormRowView? {
    guard showMonthlyStatements else { return nil }
    return FormBuilder.linkRowWith(title: "card_settings.help.monthly_statements.title".podLocalized(),
                                   subtitle: "card_settings.help.monthly_statements.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.monthlyStatementsTapped()
    }
  }

  func createLegalTitle(legalDocuments: LegalDocuments) -> FormRowView? {
    let content: [Content?] = [
      legalDocuments.cardHolderAgreement,
      legalDocuments.termsAndConditions,
      legalDocuments.privacyPolicy
    ]
    guard !(content.compactMap { return $0 }).isEmpty else {
      return nil
    }
    return FormRowSectionTitleViewTheme2(title: "card_settings.legal.title".podLocalized(), uiConfig: uiConfiguration)
  }

  func createCardholderAgreementButton(_ agreement: Content?) -> FormRowView? {
    return createContentRow(agreement,
                            title: "card_settings.legal.cardholder_agreement.title".podLocalized(),
                            subtitle: "card_settings.legal.cardholder_agreement.description".podLocalized())
  }

  func createTermsAndConditionsButton(_ termsAndConditions: Content?) -> FormRowView? {
    return createContentRow(termsAndConditions,
                            title: "card_settings.legal.terms_of_service.title".podLocalized(),
                            subtitle: "card_settings.legal.terms_of_service.description".podLocalized())
  }

  func createPrivacyPolicyButton(_ privacyPolicy: Content?) -> FormRowView? {
    return createContentRow(privacyPolicy,
                            title: "card_settings.legal.privacy_policy.title".podLocalized(),
                            subtitle: "card_settings.legal.privacy_policy.description".podLocalized())
  }

    func createExchangeRatesButton(_ privacyPolicy: Content?) -> FormRowView? {
      return createContentRow(privacyPolicy,
                              title: "card_settings.legal.exchange_rates.title".podLocalized(),
                              subtitle: "card_settings.legal.exchange_rates.description".podLocalized())
    }

  func createContentRow(_ content: Content?, title: String, subtitle: String) -> FormRowView? {
    guard let content = content else {
      return nil
    }
    return FormBuilder.linkRowWith(title: title,
                                   subtitle: subtitle,
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.show(content: content, title: title)
    }
  }

  func createChangePinRow(showButton: Bool) -> FormRowView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card_settings.settings.set_pin.title".podLocalized(),
                                   subtitle: "card_settings.settings.set_pin.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.changePinTapped()
    }
  }

  func createGetPinRow(showButton: Bool) -> FormRowView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card_settings.settings.get_pin.title".podLocalized(),
                                   subtitle: "card_settings.settings.get_pin.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.getPinTapped()
    }
  }

  func createSetPassCodeRow(showButton: Bool) -> FormRowView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card_settings.settings.passcode.title".podLocalized(),
                                   subtitle: "card_settings.settings.passcode.subtitle".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.setPassCodeTapped()
    }
  }

  func setUpLockCardRow() -> FormRowSwitchTitleSubtitleView? {
    let title = "card_settings.settings.lock_card.title".podLocalized()
    let subtitle = "card_settings.settings.lock_card.description".podLocalized()
    lockCardRow = FormBuilder.titleSubtitleSwitchRowWith(title: title,
                                                         subtitle: subtitle,
                                                         height: 72,
                                                         leftMargin: 16,
                                                         uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.lockCardChanged(switcher: switcher)
    }
    if let locked = presenter.viewModel.locked.value {
      set(lockedSwitch: locked)
    }
    lockCardRow?.showSplitter = false
    return lockCardRow
  }

  func createTransactionsTitle(showDetailedCardActivity: Bool) -> FormRowSectionTitleViewTheme2? {
    guard showDetailedCardActivity else { return nil }
    return FormRowSectionTitleViewTheme2(title: "card_settings.transactions.title".podLocalized(),
                                         uiConfig: uiConfiguration)
  }

  func createDetailedCardActivityRow(showDetailedCardActivity: Bool) -> FormRowSwitchTitleSubtitleView? {
    guard showDetailedCardActivity else { return nil }
    let title = "card_settings.transactions.detailed_card_activity.title".podLocalized()
    let subtitle = "card_settings.transactions.detailed_card_activity.description".podLocalized()
    let row = FormBuilder.titleSubtitleSwitchRowWith(title: title, subtitle: subtitle, height: 86, leftMargin: 16,
                                                     uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.showDetailedCardActivity(switcher.isOn)
    }
    row.titleSubtitleView.subtitleLabel.numberOfLines = 2
    row.switcher.isOn = presenter.viewModel.buttonsVisibility.value.isShowDetailedCardActivityEnabled
    return row
  }

  
  func setUpAddFundsRow(showButton: Bool) -> FormRowView? {
    guard showButton else { return nil }
    let addFundsRow = FormBuilder.linkRowWith(
      title: "card_settings.settings.card_add_funds.title".podLocalized(),
      subtitle: "card_settings.settings.card_add_funds.description".podLocalized(),
      leftIcon: nil,
      height: 72,
      uiConfig: uiConfiguration) { [weak self] in
        self?.presenter.didTapOnLoadFunds()
    }
    return addFundsRow
  }

  func setUpShowCardInfoRow() -> FormRowView? {
    let showCardInfoRow = FormBuilder.linkRowWith(
      title: "card_settings.settings.card_details.title".podLocalized(),
      subtitle: "card_settings.settings.card_details.description".podLocalized(),
      leftIcon: nil,
      height: 72,
      uiConfig: uiConfiguration) { [weak self] in
        self?.presenter.didTapOnShowCardInfo()
    }
    return showCardInfoRow
  }

    func addShowOrderPhysicalCardRow(showButton: Bool) -> FormRowView? {
        guard showButton else { return nil }
        let addOrderPhysicalCardRow = FormBuilder.linkRowWith(
            title: "card_settings.settings.order_physical.title".podLocalized(),
            subtitle: "",
            leftIcon: nil,
            height: 72,
            uiConfig: uiConfiguration) { [weak self] in
                self?.presenter.didTapOnOrderPhysicalCard()
        }
        addOrderPhysicalCardRow.showSplitter = true
        return addOrderPhysicalCardRow
    }
    
    func showAppleWallet(showButton: Bool) -> FormRowView? {
        guard showButton else { return nil }
        let applePayRow = ApplePayRowItemView(with: "card_settings.apple_pay.add_to_wallet.title".podLocalized(),
                                              uiconfig: uiConfiguration) { [presenter] in
            presenter.didTapOnApplePayIAP()
        }
        applePayRow.showSplitter = true
        return applePayRow
    }
}
