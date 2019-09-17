//
// FundingSourceSelectorViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import UIKit
import AptoSDK
import Bond
import ReactiveKit
import SnapKit

class FundingSourceSelectorViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: FundingSourceSelectorPresenterProtocol
  private let containerView = UIView()
  private let headerView = UIView()
  private let formView = MultiStepForm()
  private let emptyCaseContainerView = UIView()
  private let userInteractionLockerView = UIView()

  init(uiConfiguration: UIConfig, presenter: FundingSourceSelectorPresenterProtocol) {
    self.presenter = presenter
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
}

// MARK: - View model subscriptions
private extension FundingSourceSelectorViewControllerTheme2 {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    combineLatest(viewModel.fundingSources,
                  viewModel.hideReconnectButton,
                  viewModel.dataLoaded).observeNext { [unowned self] fundingSources, hideReconnectButton, dataLoaded in
      guard dataLoaded else { return }
      guard !fundingSources.isEmpty else {
        self.emptyCaseContainerView.isHidden = false
        return
      }
      self.emptyCaseContainerView.isHidden = true
      var rows: [FormRowView] = [
        self.createFundingSourceSelector(fundingSources: fundingSources)
      ]
      if !hideReconnectButton {
        rows += [ self.createAddFundingSourceButton() ]
      }
      rows += [ FormRowSeparatorView(backgroundColor: .clear, height: 16) ]
      self.formView.show(rows: rows)
    }.dispose(in: disposeBag)

    viewModel.showLoadingSpinner.observeNext { [unowned self] showLoadingView in
      self.userInteractionLockerView.isHidden = !showLoadingView
      if showLoadingView {
        self.showLoadingSpinner(tintColor: self.uiConfiguration.uiPrimaryColor,
                                position: .custom(coordinates: self.containerView.center))
      }
      else {
        self.hideLoadingSpinner()
      }
    }.dispose(in: disposeBag)
  }

  func createFundingSourceSelector(fundingSources: [FundingSource]) -> FormRowView {
    let rows = rowValuesFrom(fundingSources: fundingSources)
    let values = fundingSources.enumerated().map { (index, _) in
      return index
    }
    let selector = FormBuilder.balanceRadioRowWith(balances: rows,
                                                   values: values,
                                                   uiConfig: uiConfiguration)
    selector.bndValue.observeNext { [weak self] index in
      if let index = index {
        self?.presenter.fundingSourceSelected(index: index)
      }
    }.dispose(in: disposeBag)
    presenter.viewModel.activeFundingSourceIdx.bind(to: selector.bndValue)
    return selector
  }

  func rowValuesFrom(fundingSources: [FundingSource]) -> [FormRowBalanceRadioViewValue] {
    return fundingSources.map { fundingSource in
      guard let amount = fundingSource.balance else {
        return nil
      }
      if let wallet = fundingSource as? CustodianWallet {
        return FormRowBalanceRadioViewValue(title: wallet.custodian.name ?? "",
                                            amount: amount,
                                            subtitle: wallet.nativeBalance.text)
      }
      else {
        return FormRowBalanceRadioViewValue(title: "",
                                            amount: amount,
                                            subtitle: nil)
      }
    }.compactMap { return $0 }
  }

  func createAddFundingSourceButton() -> FormRowView {
    let button = ComponentCatalog.smallButtonWith(title: "card.settings.add-funding-source.button.title".podLocalized(),
                                                  showShadow: false,
                                                  uiConfig: uiConfiguration) {[unowned self] in
      self.presenter.addFundingSourceTapped()
    }
    let containerView = UIView()
    containerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    containerView.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(56)
      make.top.bottom.equalToSuperview().inset(12)
    }
   return FormRowCustomView(view: containerView, showSplitter: false)
  }
}

// MARK: - Set up UI
private extension FundingSourceSelectorViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.overlayBackgroundColor
    view.isOpaque = false
    setUpContainerView()
    setUpHeaderView()
    setUpFormView()
    setUpEmptyCaseContainerView()
    setUpCloseListener()
    containerView.bringSubviewToFront(headerView) // Needed to make the shadow visible
    setUpUserInteractionLockerView()
  }

  func setUpContainerView() {
    containerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    containerView.layer.cornerRadius = 8
    containerView.clipsToBounds = true
    // This is a dummy listener to avoid dismissing the view controller by tapping inside the container view
    containerView.addTapGestureRecognizer {}
    view.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.bottom.equalTo(bottomConstraint).inset(12)
      make.height.equalToSuperview().multipliedBy(0.45)
    }
  }

  func setUpHeaderView() {
    headerView.backgroundColor = containerView.backgroundColor
    headerView.layer.shadowOffset = CGSize(width: 0, height: -7)
    headerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    headerView.layer.shadowOpacity = 0
    headerView.layer.shadowRadius = 8
    containerView.addSubview(headerView)
    headerView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.height.equalTo(56)
    }
    setUpDividerView()
    setUpTitleLabel()
    setUpRefreshButton()
  }

  func setUpDividerView() {
    let dividerView = UIView()
    dividerView.backgroundColor = uiConfiguration.uiTertiaryColor
    headerView.addSubview(dividerView)
    dividerView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.left.right.equalToSuperview()
      make.height.equalTo(1)
    }
  }

  func setUpTitleLabel() {
    let label = ComponentCatalog.topBarTitleLabelWith(text: "manage_card.funding_source_selector.title".podLocalized(),
                                                      textAlignment: .left,
                                                      uiConfig: uiConfiguration)
    label.textColor = uiConfiguration.textSecondaryColor
    headerView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().inset(48)
      make.centerY.equalToSuperview()
    }
  }

  func setUpRefreshButton() {
    let button = UIButton(type: .custom)
    button.setImage(UIImage.imageFromPodBundle("btn_refresh_sources")?.asTemplate(), for: .normal)
    button.tintColor = uiConfiguration.uiPrimaryColor
    headerView.addSubview(button)
    button.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.right.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
    }
    button.addTapGestureRecognizer { [unowned self] in
      self.presenter.refreshDataTapped()
    }
  }

  func setUpFormView() {
    formView.delegate = self
    containerView.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview()
      make.top.equalTo(headerView.snp.bottom)
    }
  }

  func setUpEmptyCaseContainerView() {
    emptyCaseContainerView.backgroundColor = containerView.backgroundColor
    emptyCaseContainerView.isHidden = true
    containerView.addSubview(emptyCaseContainerView)
    emptyCaseContainerView.snp.makeConstraints { make in
      make.edges.equalTo(formView)
    }
    let buttonTitle = "manage_card.funding_source_selector.empty_case.call_to_action".podLocalized()
    let connectButton = ComponentCatalog.smallButtonWith(title: buttonTitle,
                                                         showShadow: false,
                                                         uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.addFundingSourceTapped()
    }
    emptyCaseContainerView.addSubview(connectButton)
    connectButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(56)
      make.top.equalTo(emptyCaseContainerView.snp.centerY).offset(-12)
    }
    let message = "manage_card.funding_source_selector.empty_case.message".podLocalized()
    let label = ComponentCatalog.emptyCaseLabelWith(text: message, uiConfig: uiConfiguration)
    emptyCaseContainerView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(40)
      make.bottom.equalTo(connectButton.snp.top).offset(-20)
    }
  }

  func setUpCloseListener() {
    view.addTapGestureRecognizer { [unowned self] in
      self.presenter.closeTapped()
    }
  }

  func setUpUserInteractionLockerView() {
    userInteractionLockerView.backgroundColor = .clear
    view.addSubview(userInteractionLockerView)
    userInteractionLockerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    // This is a dummy listener to avoid dismissing the view controller by tapping inside the container view
    userInteractionLockerView.addTapGestureRecognizer {}
    userInteractionLockerView.isHidden = true
  }
}

extension FundingSourceSelectorViewControllerTheme2: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y < 4 {
      headerView.layer.shadowOpacity = 0
    }
    else {
      if headerView.layer.shadowOpacity < 1 {
        headerView.layer.shadowOpacity = 1
      }
    }
  }
}
