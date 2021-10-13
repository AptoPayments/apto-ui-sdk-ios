//
// IssueCardViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/11/2018.
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class IssueCardViewControllerTheme2: AptoViewController {
  private let disposeBag = DisposeBag()
  private let presenter: IssueCardPresenterProtocol
  private let errorViewContainer = UIView()
  private var retryButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
  private let legalNoticeViewContainer = UIView()
  private let legalNoticeActionsView = UIView()
  private let legalNoticeView: ContentPresenterView
  private var currentState: IssueCardViewState?
  private var errorAsset: String?

  init(uiConfiguration: UIConfig, presenter: IssueCardPresenterProtocol) {
    self.presenter = presenter
    self.legalNoticeView = ContentPresenterView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
    self.retryButton = ComponentCatalog.buttonWith(title: " ", showShadow: false,
                                                   uiConfig: uiConfiguration) { [weak self] in
      self?.presenter.retryTapped()
    }
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

  private func setupViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.state.observeNext { [unowned self] state in
      self.updateUIForState(state)
    }.dispose(in: disposeBag)

    viewModel.errorAsset.observeNext { [unowned self] errorAsset in
      self.errorAsset = errorAsset
    }.dispose(in: disposeBag)
  }

  private func updateUIForState(_ state: IssueCardViewState) {
    guard currentState != state else {
      return
    }
    currentState = state
    switch state {
    case .loading:
      showLoadingState()
      showLoadingView()
      hideErrorState()
      hideLegalNotice()
    case .error(let error):
      hideLoadingView()
      hideLegalNotice()
      showErrorState(error: error)
    case .done:
      hideLoadingView()
    case .showLegalNotice(let content):
      hideLoadingView()
      hideErrorState()
      showLegalNotice(content)
    }
  }
}

// MARK: - setup UI
private extension IssueCardViewControllerTheme2 {
  func setUpUI() {
    updateBackgroundColor(uiConfiguration.uiBackgroundPrimaryColor)
    hideNavCancelButton()
    setUpErrorView()
    setUpLegalNoticeView()
  }

  func setUpLegalNoticeView() {
    setUpLegalNoticeContainerView()
    setUpLegalNoticeActionsView()
    setUpLegalNoticeContentView()
  }

  func setUpLegalNoticeContainerView() {
    view.addSubview(legalNoticeViewContainer)
    legalNoticeViewContainer.snp.makeConstraints { make in
      make.edges.equalTo(edgesConstraint)
    }
  }

  func setUpLegalNoticeActionsView() {
    let button = ComponentCatalog.buttonWith(title: "issue_card.issue_card.call_to_action.title".podLocalized(),
                                             showShadow: false,
                                             uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.requestCardTapped()
    }
    legalNoticeActionsView.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.top.equalToSuperview().offset(10)
      make.bottom.equalToSuperview().inset(24)
    }
    legalNoticeViewContainer.addSubview(legalNoticeActionsView)
    legalNoticeActionsView.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview()
    }
  }

  func setUpLegalNoticeContentView() {
    let titleLabel = ComponentCatalog.largeTitleLabelWith(text: "issue_card.issue_card.title".podLocalized(),
                                                          multiline: false,
                                                          uiConfig: uiConfiguration)
    titleLabel.adjustsFontSizeToFitWidth = true
    legalNoticeViewContainer.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
    legalNoticeView.font = uiConfiguration.fontProvider.mainItemLightFont
    legalNoticeView.lineSpacing = 4
    legalNoticeViewContainer.addSubview(legalNoticeView)
    legalNoticeView.delegate = self
    legalNoticeView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
      make.left.right.equalToSuperview()
      make.bottom.greaterThanOrEqualTo(legalNoticeViewContainer.snp.top)
    }
  }

  func showLoadingState() {
    hideErrorState()
    updateBackgroundColor(uiConfiguration.uiBackgroundPrimaryColor)
    setNeedsStatusBarAppearanceUpdate()
  }

  func showErrorState(error: BackendError) {
    errorViewContainer.isHidden = false
    setNeedsStatusBarAppearanceUpdate()
    showErrorView(error: error)
  }

  func showErrorView(error: BackendError) {
    navigationController?.isNavigationBarHidden = true
    let errorView = ErrorView(config: errorViewConfigFor(error: error), uiConfig: uiConfiguration)
    errorView.delegate = self
    errorView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    errorViewContainer.addSubview(errorView)
    errorView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.bottom.equalTo(retryButton.snp.top)
    }
    updateRetryButtonTitleFor(error: error)
  }
 
  func errorViewConfigFor(error: BackendError) -> ErrorViewConfiguration {
    switch error {
    case _ where error.isBalanceInsufficientFundsError:
      return ErrorViewConfiguration(
        title: "issue_card.issue_card.error_insufficient_funds.title".podLocalized(),
        description: "issue_card.issue_card.error_insufficient_funds.description".podLocalized(),
        secondaryCTA: "issue_card.issue_card.error_insufficient_funds.secondary_cta".podLocalized(),
        assetURL: errorAsset
      )
    case _ where error.isBalanceValidationsInsufficientApplicationLimit:
      return ErrorViewConfiguration(
        title: "issue_card.issue_card.error_insufficient_application_limit.title".podLocalized(),
        description: "issue_card.issue_card.error_insufficient_application_limit.description".podLocalized(),
        secondaryCTA: "issue_card.issue_card.error_insufficient_application_limit.secondary_cta".podLocalized(),
        assetURL: errorAsset
      )
    case _ where error.isBalanceValidationsEmailSendsDisabled:
      return ErrorViewConfiguration(
        title: "issue_card.issue_card.error_email_sends_disabled.title".podLocalized(),
        description: "issue_card.issue_card.error_email_sends_disabled.description".podLocalized(),
        secondaryCTA: "issue_card.issue_card.error_email_sends_disabled.secondary_cta".podLocalized(),
        assetURL: errorAsset
      )
    default:
      return ErrorViewConfiguration(
        title: "issue_card.issue_card.generic_error.title".podLocalized(),
        description: "issue_card.issue_card.generic_error.description".podLocalized(),
        secondaryCTA: "issue_card.issue_card.generic_error.secondary_cta".podLocalized(),
        assetURL: errorAsset
      )
    }
  }

  func hideErrorState() {
    errorViewContainer.isHidden = true
  }

  func showLegalNotice(_ content: Content) {
    updateBackgroundColor(uiConfiguration.uiBackgroundPrimaryColor)
    legalNoticeView.set(content: content)
    legalNoticeViewContainer.isHidden = false
  }

  func hideLegalNotice() {
    legalNoticeViewContainer.isHidden = true
  }

  func updateBackgroundColor(_ color: UIColor) {
    view.backgroundColor = color
    navigationController?.navigationBar.setUp(barTintColor: color, tintColor: color)
  }

  func setUpErrorView() {
    errorViewContainer.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    view.addSubview(errorViewContainer)
    errorViewContainer.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    setUpRetryButton()
  }

  func setUpRetryButton() {
    updateRetryButtonTitleFor(error: nil)
    errorViewContainer.addSubview(retryButton)
    retryButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(54)
      make.left.right.equalToSuperview().inset(20)
    }
  }

  func updateRetryButtonTitleFor(error: BackendError?) {
    let title: String
    
    switch error {
    case _ where error?.isBalanceInsufficientFundsError == true:
      title = "issue_card.issue_card.error_insufficient_funds.primary_cta".podLocalized()
    case _ where error?.isBalanceValidationsInsufficientApplicationLimit == true:
      title = "issue_card.issue_card.error_insufficient_application_limit.primary_cta".podLocalized()
    case _ where error?.isBalanceValidationsEmailSendsDisabled == true:
      title = "issue_card.issue_card.error_email_sends_disabled.primary_cta".podLocalized()
    default:
      title = "issue_card.issue_card.generic_error.primary_cta".podLocalized()
    }
    retryButton.updateAttributedTitle(title, for: .normal)
  }
}

extension IssueCardViewControllerTheme2: ContentPresenterViewDelegate, ErrorViewDelegate {
  func linkTapped(url: TappedURL) {
    presenter.show(url: url)
  }
}
