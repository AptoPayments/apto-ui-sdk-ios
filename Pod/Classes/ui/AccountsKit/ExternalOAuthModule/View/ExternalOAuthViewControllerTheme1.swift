//
//  ExternalOAuthViewControllerTheme1.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 03/06/2018.
//
//

import Foundation
import AptoSDK
import SnapKit
import ReactiveKit

class ExternalOAuthViewControllerTheme1: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: ExternalOAuthPresenterProtocol
  private let imageView = UIImageView()
  private let accessDescriptionLabel: UILabel
  private let providerLabel: UILabel
  // swiftlint:disable implicitly_unwrapped_optional
  private var actionButton: UIButton!
  private var newUserButton: ContentPresenterView!
  // swiftlint:enable implicitly_unwrapped_optional
  private let descriptionLabel: UILabel
  private var allowedBalanceTypes = [AllowedBalanceType]()

  init(uiConfiguration: UIConfig, eventHandler: ExternalOAuthPresenterProtocol) {
    self.presenter = eventHandler
    let accessDescription = "select_balance_store.login.explanation".podLocalized()
    self.accessDescriptionLabel = ComponentCatalog.formListLabelWith(text: accessDescription,
                                                                     textAlignment: .center,
                                                                     multiline: true,
                                                                     uiConfig: uiConfiguration)
    self.providerLabel = ComponentCatalog.amountBigLabelWith(text: "external-oauth.coinbase.connect".podLocalized(),
                                                             textAlignment: .center,
                                                             uiConfig: uiConfiguration)
    let description = "external-oauth.coinbase.description".podLocalized()
    self.descriptionLabel = ComponentCatalog.instructionsLabelWith(text: description,
                                                                   textAlignment: .center,
                                                                   uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
    let callToActionTitle = "select_balance_store.login.call_to_action.title".podLocalized()
    self.actionButton = ComponentCatalog.buttonWith(title: callToActionTitle,
                                                    uiConfig: uiConfiguration) { [unowned self] in
      let custodianType: CustodianType = self.allowedBalanceTypes.first?.type ?? .coinbase
      self.custodianSelected(type: custodianType)
    }
    let newUserTitle = "select_balance_store.login.new_user.title".podLocalized()
    self.newUserButton = ComponentCatalog.anchorLinkButtonWith(title: newUserTitle,
                                                               delegate: self,
                                                               uiConfig: uiConfiguration)
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

  private func custodianSelected(type: CustodianType) {
    if let balanceType = allowedBalanceTypes.first(where: { $0.type == type }) {
      presenter.balanceTypeTapped(balanceType)
    }
    else {
      showMessage("external-oauth.wrong-type.error".podLocalized())
    }
  }
}

// MARK: - Set viewModel subscriptions
private extension ExternalOAuthViewControllerTheme1 {
  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.title.ignoreNils().observeNext { [unowned self] title in
      self.set(title: title)
    }.dispose(in: disposeBag)

    viewModel.allowedBalanceTypes.ignoreNils().observeNext { [unowned self] allowedBalanceTypes in
      self.allowedBalanceTypes = allowedBalanceTypes
    }.dispose(in: disposeBag)

    viewModel.error.ignoreNils().observeNext { [unowned self] error in
      self.show(error: error)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension ExternalOAuthViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    edgesForExtendedLayout = UIRectEdge()
    extendedLayoutIncludesOpaqueBars = true
    showNavPreviousButton(uiConfiguration.iconTertiaryColor)

    setUpImageView()
    setUpProviderLabel()
    setUpAccessDescriptionLabel()
    setUpActionButton()
    setUpDescriptionLabel()
    setUpNewUserButton()
  }

  func setUpImageView() {
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage.imageFromPodBundle("coinbase_logo")
    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(88)
      make.centerX.equalToSuperview()
      make.height.equalTo(48)
      make.width.equalTo(180)
    }
  }

  func setUpProviderLabel() {
    view.addSubview(providerLabel)
    providerLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(40)
      make.left.right.equalToSuperview().inset(18)
    }
  }

  func setUpAccessDescriptionLabel() {
    view.addSubview(accessDescriptionLabel)
    accessDescriptionLabel.snp.makeConstraints { make in
      make.left.right.equalTo(providerLabel)
      make.top.equalTo(providerLabel.snp.bottom).offset(4)
    }
  }

  func setUpActionButton() {
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.top.equalTo(accessDescriptionLabel.snp.bottom).offset(60)
      make.left.right.equalToSuperview().inset(44)
    }
  }

  func setUpDescriptionLabel() {
    view.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(actionButton.snp.bottom).offset(32)
      make.left.right.equalToSuperview().inset(64)
    }
  }

  private func setUpNewUserButton() {
    view.addSubview(newUserButton)
    newUserButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
    }
  }
}

extension ExternalOAuthViewControllerTheme1: ContentPresenterViewDelegate {
  func linkTapped(url: TappedURL) {
    presenter.newUserTapped(url: url.url)
  }
}
