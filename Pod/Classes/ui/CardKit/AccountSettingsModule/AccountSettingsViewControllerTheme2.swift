//
// AccountSettingsViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/12/2018.
//

import UIKit
import AptoSDK
import SnapKit
import ReactiveKit

class AccountSettingsViewControllerTheme2: AccountSettingsViewProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: AccountSettingsPresenterProtocol
  private let titleContainerView = UIView()
  private let formView = MultiStepForm()
  private var biometricRow: FormRowSwitchTitleSubtitleView?

  init(uiConfiguration: UIConfig, presenter: AccountSettingsPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  private func logoutTapped() {
    let cancelTitle = "account_settings.logout.confirm_logout.cancel_button".podLocalized()
    UIAlertController.confirm(title: "account_settings.logout.confirm_logout.title".podLocalized(),
                              message: "account_settings.logout.confirm_logout.message".podLocalized(),
                              okTitle: "account_settings.logout.confirm_logout.ok_button".podLocalized(),
                              cancelTitle: cancelTitle) { [unowned self] action in
      guard action.title != cancelTitle else {
        return
      }
      self.presenter.logoutTapped()
    }
  }
}

extension AccountSettingsViewControllerTheme2: UIScrollViewDelegate {
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

private extension AccountSettingsViewControllerTheme2 {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    combineLatest(viewModel.showNotificationPreferences,
                  viewModel.showMonthlyStatements,
                  viewModel.showChangePasscode,
                  viewModel.biometryType).observeNext { [unowned self] showNotification, showStatements,
                    showChangePasscode, biometryType in
      self.updateUpFormViewContent(showNotification, showStatements, showChangePasscode, biometryType)
    }.dispose(in: disposeBag)

    viewModel.isBiometricEnabled.observeNext{ [unowned self] isBiometricEnabled in
      self.biometricRow?.switcher.isOn = isBiometricEnabled
    }.dispose(in: disposeBag)
  }

  func updateUpFormViewContent(_ showNotificationPreferences: Bool, _ showMonthlyStatements: Bool,
                               _ showChangePasscode: Bool, _ biometryType: BiometryType) {
    var rows: [FormRowView] = [FormRowSeparatorView(backgroundColor: .clear, height: 16)]
    if showChangePasscode || biometryType != .none {
      rows += [self.createSecuritySettingsTitle()]
    }
    if showChangePasscode {
      rows += [self.createChangePasscodeButton(showSplitter: biometryType != .none)]
    }
    if biometryType != .none {
      rows += [self.createBiometricButton(biometryType)]
    }
    if showNotificationPreferences {
      rows += [
        self.createAppSettingsTitle(),
        self.createNotificationsButton()
      ]
    }
    rows += [
      self.createSupportTitle(),
      self.createSupportButton()
    ]
    if showMonthlyStatements {
      rows += [createStatementsButton()]
    }
    rows += [
      self.createVersionRow(),
      self.createLogoutButton()
    ]
    formView.show(rows: rows)
  }
}

// MARK: - Set up UI
private extension AccountSettingsViewControllerTheme2 {
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
    let titleLabel = ComponentCatalog.topBarTitleBigLabelWith(text: "account_settings.settings.title".podLocalized(),
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

  func createSecuritySettingsTitle() -> FormRowView {
    return FormRowSectionTitleViewTheme2(title: "account_settings.security.title".podLocalized(),
                                         uiConfig: uiConfiguration)
  }

  func createChangePasscodeButton(showSplitter: Bool) -> FormRowView {
    return FormBuilder.linkRowWith(title: "account_settings.security.change_pin.title".podLocalized(),
                                   subtitle: "account_settings.security.change_pin.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   showSplitter: showSplitter,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.changePasscodeTapped()
    }
  }

  func createBiometricButton(_ biometryType: BiometryType) -> FormRowView {
    let title = biometryType == .faceID
      ? "account_settings.security.face_id.title".podLocalized()
      : "account_settings.security.touch_id.title"
    let subtitle = biometryType == .faceID
      ? "account_settings.security.face_id.description".podLocalized()
      : "account_settings.security.touch_id.description".podLocalized()
    let retVal = FormBuilder.titleSubtitleSwitchRowWith(title: title,
                                                        subtitle: subtitle,
                                                        height: 72,
                                                        leftMargin: 16,
                                                        uiConfig: uiConfiguration) { [unowned self] switcher in
      self.presenter.changeShowBiometricTapped(switcher.isOn)
    }
    biometricRow = retVal
    biometricRow?.switcher.isOn = presenter.viewModel.isBiometricEnabled.value
    return retVal
  }

  func createAppSettingsTitle() -> FormRowView {
    return FormRowSectionTitleViewTheme2(title: "account_settings.app_settings.title".podLocalized(),
                                         uiConfig: uiConfiguration)
  }

  func createNotificationsButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "account_settings.app_settings.notifications.title".podLocalized(),
                                   subtitle: "account_settings.app_settings.notifications.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   showSplitter: false,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.notificationsTapped()
    }
  }

  func createSupportTitle() -> FormRowView {
    return FormRowSectionTitleViewTheme2(title: "account_settings.help.title".podLocalized(), uiConfig: uiConfiguration)
  }

  func createSupportButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "account_settings.help.contact_support.title".podLocalized(),
                                   subtitle: "account_settings.help.contact_support.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.contactTapped()
    }
  }

  func createStatementsButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "card_settings.help.monthly_statements.title".podLocalized(),
                                   subtitle: "card_settings.help.monthly_statements.description".podLocalized(),
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.monthlyStatementsTapped()
    }
  }

  func createVersionRow() -> FormRowView {
    return FormBuilder.linkRowWith(title: "account_settings.app.version.title".podLocalized(),
                                   subtitle: ShiftSDK.fullVersion,
                                   leftIcon: nil,
                                   height: 72,
                                   showAccessoryView: false,
                                   uiConfig: uiConfiguration) {}
  }

  func createLogoutButton() -> FormRowView {
    return FormBuilder.linkRowWith(title: "account_settings.logout.title".podLocalized(),
                                   subtitle: "",
                                   leftIcon: nil,
                                   height: 72,
                                   uiConfig: uiConfiguration) { [unowned self] in
      self.logoutTapped()
    }
  }
}
