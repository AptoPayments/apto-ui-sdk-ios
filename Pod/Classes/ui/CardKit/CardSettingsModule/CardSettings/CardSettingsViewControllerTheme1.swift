//
//  CardSettingsViewControllerTheme1.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit
import SnapKit
import PullToRefreshKit

class CardSettingsViewControllerTheme1: ShiftViewController, CardSettingsViewProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: CardSettingsPresenterProtocol
  private let formView = MultiStepForm()
  private var lockCardRow: FormRowSwitchTitleSubtitleView?
  private var showCardInfoRow: FormRowSwitchTitleSubtitleView?

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

  private func set(showCardInfoSwitch: Bool) {
    self.showCardInfoRow?.switcher.isOn = showCardInfoSwitch
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

// MARK: - Set up UI
private extension CardSettingsViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpFormView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    self.title = "card_settings.settings.title".podLocalized()
  }

  func setUpFormView() {
    view.addSubview(self.formView)
    formView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview()
    }
    formView.backgroundColor = view.backgroundColor
  }
}

// MARK: - View model subscriptions
private extension CardSettingsViewControllerTheme1 {
  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    combineLatest(viewModel.showChangePin,
                  viewModel.showGetPin,
                  viewModel.legalDocuments,
                  viewModel.showIVRSupport,
                  viewModel.showDetailedCardActivity,
                  viewModel.showMonthlyStatements).observeNext { [unowned self] showChangePin, showGetPin,
                    legalDocuments, showIVRSupport, showDetailedCardActivity, showMonthlyStatements in
      let rows = [
        self.createSettingsTitle(),
        self.createChangePinRow(showButton: showChangePin),
        self.createGetPinRow(showButton: showGetPin),
        self.setUpShowCardInfoRow(),
        self.setUpLockCardRow(),
        self.createTransactionsTitle(showDetailedCardActivity: showDetailedCardActivity),
        self.createDetailedCardActivityRow(showDetailedCardActivity: showDetailedCardActivity),
        self.createSupportTitle(),
        self.createIvrSupport(showIVRSupport),
        self.createHelpButton(),
        self.createLostCardButton(),
        self.createFAQButton(legalDocuments.faq),
        self.createStatementsButton(showMonthlyStatements),
        self.createLegalTitle(legalDocuments: legalDocuments),
        self.createCardholderAgreementButton(legalDocuments.cardHolderAgreement),
        self.createTermsAndConditionsButton(legalDocuments.termsAndConditions),
        self.createPrivacyPolicyButton(legalDocuments.privacyPolicy)
      ].compactMap { return $0 }
      self.formView.show(rows: rows)
    }.dispose(in: disposeBag)

    viewModel.locked.observeNext { [unowned self] locked in
      if let locked = locked {
        self.set(lockedSwitch: locked)
      }
    }.dispose(in: disposeBag)

    viewModel.showCardInfo.observeNext { [unowned self] showInfo in
      if let showInfo = showInfo {
        self.set(showCardInfoSwitch: showInfo)
      }
    }.dispose(in: disposeBag)
  }

  func createSettingsTitle() -> FormRowLabelView {
    return FormBuilder.sectionTitleRowWith(text: "card_settings.settings.settings.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
  }

  func createSupportTitle() -> FormRowLabelView {
    return FormBuilder.sectionTitleRowWith(text: "card_settings.help.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
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
                                   uiConfig: uiConfiguration) { [unowned self] in
                                    self.presenter.helpTapped()
    }
  }

  func createLostCardButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "card_settings.help.report_lost_card.title".podLocalized(),
                                   subtitle: "card_settings.help.report_lost_card.description".podLocalized(),
                                   leftIcon: nil,
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
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.monthlyStatementsTapped()
    }
  }

  func createLegalTitle(legalDocuments: LegalDocuments) -> FormRowLabelView? {
    let content: [Content?] = [
      legalDocuments.cardHolderAgreement,
      legalDocuments.termsAndConditions,
      legalDocuments.privacyPolicy
    ]
    guard !(content.compactMap { return $0 }).isEmpty else {
      return nil
    }
    return FormBuilder.sectionTitleRowWith(text: "card_settings.legal.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: self.uiConfiguration)
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

  func createContentRow(_ content: Content?, title: String, subtitle: String) -> FormRowView? {
    guard let content = content else {
      return nil
    }
    return FormBuilder.linkRowWith(title: title,
                                   subtitle: subtitle,
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.show(content: content, title: title)
    }
  }

  func createChangePinRow(showButton: Bool) -> FormRowView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card_settings.settings.set_pin.title".podLocalized(),
                                   subtitle: "card_settings.settings.set_pin.description".podLocalized(),
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.changePinTapped()
    }
  }

  func createGetPinRow(showButton: Bool) -> FormRowView? {
    guard showButton else { return nil }
    return FormBuilder.linkRowWith(title: "card_settings.settings.get_pin.title".podLocalized(),
                                   subtitle: "card_settings.settings.get_pin.description".podLocalized(),
                                   leftIcon: nil,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.getPinTapped()
    }
  }

  func setUpLockCardRow() -> FormRowSwitchTitleSubtitleView? {
    lockCardRow = FormBuilder.titleSubtitleSwitchRowWith(title: "card_settings.settings.lock_card.title".podLocalized(),
                                                         subtitle: "card_settings.settings.lock_card.description".podLocalized(),
                                                         uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.lockCardChanged(switcher: switcher)
    }
    if let locked = presenter.viewModel.locked.value {
      set(lockedSwitch: locked)
    }
    return lockCardRow
  }

  func createTransactionsTitle(showDetailedCardActivity: Bool) -> FormRowLabelView? {
    guard showDetailedCardActivity else { return nil }
    return FormBuilder.sectionTitleRowWith(text: "card_settings.transactions.title".podLocalized(),
                                           textAlignment: .left,
                                           uiConfig: uiConfiguration)
  }

  func createDetailedCardActivityRow(showDetailedCardActivity: Bool) -> FormRowSwitchTitleSubtitleView? {
    guard showDetailedCardActivity else { return nil }
    let title = "card_settings.transactions.detailed_card_activity.title".podLocalized()
    let subtitle = "card_settings.transactions.detailed_card_activity.description".podLocalized()
    let row = FormBuilder.titleSubtitleSwitchRowWith(title: title, subtitle: subtitle, height: 72,
                                                     uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.showDetailedCardActivity(switcher.isOn)
    }
    row.titleSubtitleView.subtitleLabel.numberOfLines = 2
    row.switcher.isOn = presenter.viewModel.isShowDetailedCardActivityEnabled.value
    return row
  }

  func setUpShowCardInfoRow() -> FormRowSwitchTitleSubtitleView? {
    showCardInfoRow = FormBuilder.titleSubtitleSwitchRowWith(title: "card_settings.settings.card_details.title".podLocalized(),
                                                             subtitle: "card_settings.settings.card_details.description".podLocalized(),
                                                             uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.showCardInfoChanged(switcher: switcher)
    }
    if let showInfo = presenter.viewModel.showCardInfo.value {
      set(showCardInfoSwitch: showInfo)
    }
    return showCardInfoRow
  }
}
