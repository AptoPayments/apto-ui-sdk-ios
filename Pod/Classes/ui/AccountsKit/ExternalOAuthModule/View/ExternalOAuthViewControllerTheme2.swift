//
// ExternalOAuthViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 12/11/2018.
//

import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class ExternalOAuthViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: ExternalOAuthPresenterProtocol
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var explanationLabel: UILabel!
  private var actionButton: UIButton!
  private var newUserButton: ContentPresenterView!
  // swiftlint:enable implicitly_unwrapped_optional
  private var allowedBalanceTypes = [AllowedBalanceType]()

  init(uiConfiguration: UIConfig, eventHandler: ExternalOAuthPresenterProtocol) {
    self.presenter = eventHandler
    super.init(uiConfiguration: uiConfiguration)
    self.actionButton = ComponentCatalog.buttonWith(title: " ",
                                                    showShadow: false,
                                                    uiConfig: uiConfiguration) { [unowned self] in
      let custodianType: String = self.allowedBalanceTypes.first?.type ?? ""
      self.custodianSelected(type: custodianType)
    }
    self.newUserButton = ComponentCatalog.anchorLinkButtonWith(title: " ",
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

  private func custodianSelected(type: String) {
    if let balanceType = allowedBalanceTypes.first(where: { $0.type == type }) {
      presenter.balanceTypeTapped(balanceType)
    }
    else {
      showMessage("external-oauth.wrong-type.error".podLocalized())
    }
  }
}

// MARK: - Set viewModel subscriptions
private extension ExternalOAuthViewControllerTheme2 {
  func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.title.ignoreNils().observeNext { [unowned self] title in
      self.titleLabel.updateAttributedText(title)
    }.dispose(in: disposeBag)

    viewModel.explanation.ignoreNils().observeNext { [unowned self] explanation in
      self.explanationLabel.updateAttributedText(explanation)
    }.dispose(in: disposeBag)

    viewModel.callToAction.ignoreNils().observeNext { [unowned self] callToAction in
      self.actionButton.updateAttributedTitle(callToAction, for: .normal)
    }.dispose(in: disposeBag)

    viewModel.newUserAction.ignoreNils().observeNext { [unowned self] newUserAction in
      self.newUserButton.set(content: .plainText(newUserAction))
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
private extension ExternalOAuthViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    edgesForExtendedLayout = UIRectEdge()
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpNewUserButton()
    setUpActionButton()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.textTopBarPrimaryColor)
  }

  func setUpTitleLabel() {
    titleLabel = ComponentCatalog.largeTitleLabelWith(text: " ", multiline: true, uiConfig: uiConfiguration)
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpExplanationLabel() {
    explanationLabel = ComponentCatalog.formLabelWith(text: " ",
                                                      multiline: true,
                                                      lineSpacing: uiConfiguration.lineSpacing,
                                                      letterSpacing: uiConfiguration.letterSpacing,
                                                      uiConfig: uiConfiguration)
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
  }

  private func setUpNewUserButton() {
    view.addSubview(newUserButton)
    newUserButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(54)
    }
  }

  func setUpActionButton() {
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalTo(newUserButton.snp.top)
    }
  }
}

extension ExternalOAuthViewControllerTheme2: ContentPresenterViewDelegate {
  func linkTapped(url: TappedURL) {
    presenter.newUserTapped(url: url.url)
  }
}
