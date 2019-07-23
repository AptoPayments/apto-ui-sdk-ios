//
// KYCViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 11/03/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class KYCViewControllerTheme2: KYCViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: KYCPresenterProtocol
  private let titleLabel: UILabel
  private let statusLabel: UILabel
  private let footerLabel: ContentPresenterView

  init(uiConfiguration: UIConfig, presenter: KYCPresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "manage_card.kyc.title".podLocalized(),
                                                           textAlignment: .center,
                                                           uiConfig: uiConfiguration)
    self.statusLabel = ComponentCatalog.formLabelWith(text: " ",
                                                      textAlignment: .center,
                                                      multiline: true,
                                                      lineSpacing: uiConfiguration.lineSpacing,
                                                      letterSpacing: uiConfiguration.letterSpacing,
                                                      uiConfig: uiConfiguration)
    self.footerLabel = ContentPresenterView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
  }

  required public init?(coder aDecoder: NSCoder) {
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
}

private extension KYCViewControllerTheme2 {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.kycState.observeNext { [unowned self] kycState in
      self.statusLabel.updateAttributedText(self.kycStateDescription(kyc: kycState))
    }.dispose(in: disposeBag)
  }

  private func kycStateDescription(kyc: KYCState?) -> String {
    guard let kyc = kyc else {
      return " " // We need an empty string to not lose the attributes of the label
    }
    switch kyc {
    case .resubmitDetails:
      return "manage_card.kyc.state.resubmit_details".podLocalized()
    case .uploadFile:
      return "manage_card.kyc.state.upload_file".podLocalized()
    case .underReview:
      return "manage_card.kyc.state.under_review".podLocalized()
    case .passed:
      return "manage_card.kyc.state.passed".podLocalized()
    case .rejected:
      return "manage_card.kyc.state.rejected".podLocalized()
    case .temporaryError:
      return "manage_card.kyc.state.temporary_error".podLocalized()
    }
  }
}

// MARK: - Set up UI
private extension KYCViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    let containerView = createContainerView()
    setUpTitleLabel(containerView: containerView)
    setUpStatusLabel(containerView: containerView)
    setUpFooterLabel()
    createRefreshButton()
  }

  func setUpNavigationBar() {
    navigationController?.isNavigationBarHidden = true
  }

  func createContainerView() -> UIView {
    let containerView = UIView()
    view.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    return containerView
  }

  func setUpTitleLabel(containerView: UIView) {
    containerView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(68)
    }
  }

  func setUpStatusLabel(containerView: UIView) {
    containerView.addSubview(statusLabel)
    statusLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.left.right.equalToSuperview().inset(32)
      make.bottom.equalToSuperview()
    }
  }

  func setUpFooterLabel() {
    view.addSubview(footerLabel)
    footerLabel.textAlignment = .center
    footerLabel.underlineLinks = true
    footerLabel.linkColor = uiConfiguration.textSecondaryColor
    footerLabel.font = uiConfiguration.fontProvider.formTextLink
    footerLabel.delegate = self
    footerLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(46)
      make.bottom.equalTo(bottomConstraint).inset(16)
    }
    footerLabel.set(content: .plainText("manage_card.kyc.footer".podLocalized()))
  }

  func createRefreshButton() {
    let refreshButton = ComponentCatalog.buttonWith(title: "manage_card.kyc.call_to_action.title".podLocalized(),
                                                    showShadow: false,
                                                    uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.refreshTapped()
    }
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalTo(footerLabel.snp.top).offset(4)
    }
  }
}

extension KYCViewControllerTheme2: ContentPresenterViewDelegate {
  func linkTapped(url: TappedURL) {
    presenter.show(url: url.url)
  }
}
