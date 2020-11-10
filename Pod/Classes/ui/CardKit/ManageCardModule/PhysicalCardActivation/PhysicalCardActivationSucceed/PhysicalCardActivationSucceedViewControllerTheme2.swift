//
//  PhysicalCardActivationSucceedViewControllerTheme2.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 28/12/2018.
//

import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class PhysicalCardActivationSucceedViewControllerTheme2: PhysicalCardActivationSucceedViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PhysicalCardActivationSucceedPresenterProtocol
  private let labelsContainerView = UIView()
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private let chargeLabelContainerView = UIView()

  init(uiConfiguration: UIConfig, presenter: PhysicalCardActivationSucceedPresenterProtocol) {
    self.presenter = presenter
    let title = "manage_card.get_pin_nue.title".podLocalized()
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: title, textAlignment: .center,
                                                           uiConfig: uiConfiguration)
    let explanation = "manage_card.get_pin_nue.explanation".podLocalized()
    self.explanationLabel = ComponentCatalog.formLabelWith(text: explanation, textAlignment: .center, multiline: true,
                                                           uiConfig: uiConfiguration)
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

// MARK: - View model subscriptions
private extension PhysicalCardActivationSucceedViewControllerTheme2 {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.showGetPinButton.observeNext { [unowned self] _ in
      self.setUpPinButton()
    }.dispose(in: disposeBag)
    viewModel.showChargeLabel.observeNext { [unowned self] _ in
      self.setUpChargeLabel()
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension PhysicalCardActivationSucceedViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpNavigationBar()
    setUpLabels()
    setUpChargeLabelContainerView()
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

  func setUpLabels() {
    labelsContainerView.backgroundColor = view.backgroundColor
    view.addSubview(labelsContainerView)
    labelsContainerView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-44)
      make.left.right.equalToSuperview().inset(44)
    }
    setUpTitleLabel()
    setUpExplanationLabel()
  }

  func setUpTitleLabel() {
    labelsContainerView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
    }
  }

  func setUpExplanationLabel() {
    labelsContainerView.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
    }
  }

  func setUpChargeLabelContainerView() {
    chargeLabelContainerView.backgroundColor = view.backgroundColor
    view.addSubview(chargeLabelContainerView)
    chargeLabelContainerView.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview()
      make.height.greaterThanOrEqualTo(22)
    }
  }

  func setUpPinButton() {
    if presenter.viewModel.showGetPinButton.value {
      createGetPinButton()
    }
  }

  func createGetPinButton() {
    let button = ComponentCatalog.buttonWith(title: "manage_card.get_pin_nue.call_to_action.title".podLocalized(),
                                             showShadow: false, accessibilityLabel: "Get PIN button",
                                             uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.getPinTapped()
    }
    view.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalTo(chargeLabelContainerView.snp.top).offset(-32)
    }
  }

  func setUpChargeLabel() {
    if presenter.viewModel.showGetPinButton.value {
      createChargeApplyLabel()
    }
    else {
      chargeLabelContainerView.subviews.forEach { $0.removeFromSuperview() }
    }
  }

  func createChargeApplyLabel() {
    let chargeExplanation = "manage_card.get_pin_nue.footer".podLocalized()
    let label = ComponentCatalog.instructionsLabelWith(text: chargeExplanation, uiConfig: uiConfiguration)
    chargeLabelContainerView.addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalToSuperview().inset(44)
    }
  }
}
