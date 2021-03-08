//
// FullScreenDisclaimerViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 15/11/2018.
//

import UIKit
import AptoSDK
import TTTAttributedLabel
import Bond
import ReactiveKit
import SnapKit

class FullScreenDisclaimerViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let eventHandler: FullScreenDisclaimerEventHandler
  private let titleLabel: UILabel
  private let contentPresenterView: ContentPresenterView
  private let navigationView = UIView()
  private var agreeButton: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional
    private var callToActionTitle: String
    private var cancelActionTitle: String
    
  init(uiConfiguration: UIConfig,
       eventHandler: FullScreenDisclaimerEventHandler,
       disclaimerTitle: String,
       callToActionTitle: String,
       cancelActionTitle: String) {
    self.eventHandler = eventHandler
    self.contentPresenterView = ContentPresenterView(uiConfig: uiConfiguration)
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: disclaimerTitle.podLocalized(),
                                                           uiConfig: uiConfiguration)
    self.callToActionTitle = callToActionTitle
    self.cancelActionTitle = cancelActionTitle
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setupViewModelSubscriptions()
    eventHandler.viewLoaded()
  }

  // Setup viewModel subscriptions
  private func setupViewModelSubscriptions() {
    let viewModel = eventHandler.viewModel

    viewModel.disclaimer.ignoreNils().observeNext { [unowned self] disclaimer in
      self.set(disclaimer: disclaimer)
    }.dispose(in: disposeBag)
  }

  final private func set(disclaimer: Content) {
    if case .externalURL(_) = disclaimer {
      agreeButton.isEnabled = false
      agreeButton.backgroundColor = uiConfiguration.uiPrimaryColorDisabled
    }
    contentPresenterView.set(content: disclaimer)
    if case let .nativeContent(nativeContent) = disclaimer {
      let title = "disclaimer.native_content.title".podLocalized()
      let mainDescription = "disclaimer.native_content.description.main".podLocalized()
      let secondaryDescription = "disclaimer.native_content.description.secondary".podLocalized()
      contentPresenterView.set(title: title)
      contentPresenterView.set(mainDescription: mainDescription)
      contentPresenterView.set(secondaryDescription: secondaryDescription)
      titleLabel.isHidden = true
      setUpContentPresenterView(showTitle: false)
      view.sendSubviewToBack(contentPresenterView)
      navigationView.backgroundColor = .clear
      view.backgroundColor = nativeContent.dynamicBackgroundColor
      navigationView.backgroundColor = view.backgroundColor
    }
    else {
      setUpContentPresenterView(showTitle: true)
    }
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }

  func agreeTapped() {
    eventHandler.agreeTapped()
  }
}

extension FullScreenDisclaimerViewControllerTheme2: ContentPresenterViewDelegate {
  func linkTapped(url: TappedURL) {
    eventHandler.linkTapped(url.url)
  }

  func didScrollToBottom() {
    guard !agreeButton.isEnabled else {
      return
    }
    agreeButton.isEnabled = true
    agreeButton.backgroundColor = uiConfiguration.uiPrimaryColor
  }
}

private extension FullScreenDisclaimerViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.disclaimerBackgroundColor
    extendedLayoutIncludesOpaqueBars = true
    automaticallyAdjustsScrollViewInsets = true
    edgesForExtendedLayout = .top

    setUpNavigationBar()
    setUpTitleLabel()
    // Bottom Bar Buttons
    setUpNavigationView()
    setUpAgreeButton()
    setUpCancelButton()
  }

  func setUpNavigationBar() {
    navigationController?.isNavigationBarHidden = true
  }

  func setUpTitleLabel() {
    titleLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalTo(topConstraint).offset(16)
      make.height.equalTo(62)
    }
  }

  func setUpNavigationView() {
    navigationView.backgroundColor = view.backgroundColor
    view.addSubview(navigationView)
    navigationView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
    }
  }

  func setUpAgreeButton() {
    agreeButton = ComponentCatalog.buttonWith(title: callToActionTitle.podLocalized(),
                                              showShadow: false,
                                              uiConfig: uiConfiguration) { [unowned self] in
      self.agreeTapped()
    }
    navigationView.addSubview(agreeButton)
    agreeButton.snp.makeConstraints { make in
      make.left.top.right.equalTo(navigationView).inset(20)
    }
  }

  func setUpCancelButton() {
    let title = cancelActionTitle.podLocalized()
    let button = ComponentCatalog.formTextLinkButtonWith(title: title,
                                                         uiConfig: uiConfiguration) { [unowned self] in
      self.closeTapped()
    }
    navigationView.addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalTo(agreeButton.snp.bottom).offset(4)
      make.left.right.equalTo(agreeButton)
      make.bottom.equalTo(bottomConstraint).inset(12)
    }
  }

  func setUpContentPresenterView(showTitle: Bool = true) {
    contentPresenterView.removeFromSuperview()
    contentPresenterView.snp.removeConstraints()
    contentPresenterView.font = uiConfiguration.fontProvider.mainItemLightFont
    contentPresenterView.lineSpacing = 4
    view.addSubview(contentPresenterView)
    contentPresenterView.delegate = self
    contentPresenterView.snp.makeConstraints { make in
      if showTitle {
        make.top.equalTo(titleLabel.snp.bottom).offset(16)
      }
      else {
        make.top.equalTo(topConstraint)
      }
      make.left.right.equalToSuperview()
      make.bottom.equalTo(navigationView.snp.top)
    }
  }
}
