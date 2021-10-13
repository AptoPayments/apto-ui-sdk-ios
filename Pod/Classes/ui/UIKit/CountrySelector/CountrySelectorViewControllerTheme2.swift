//
// CountrySelectorViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 16/05/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class CountrySelectorViewControllerTheme2: AptoViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: CountrySelectorPresenterProtocol
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private let countryList = UITableView(frame: .zero, style: .plain)
  private let bottomContainerView = UIView()
  private var selectCountryButton: UIButton?
  private var selectedController: CountryCellController? {
    didSet {
      let isEnabled = selectedController != nil
      updateSelectButtonState(isEnabled: isEnabled)
    }
  }
  private var cellControllers: [CountryCellController] = []

  init(uiConfiguration: UIConfig, presenter: CountrySelectorPresenterProtocol) {
    self.presenter = presenter
    let title = "select_card_product.select_country.title".podLocalized()
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: title, multiline: true, uiConfig: uiConfiguration)
    let explanation = "select_card_product.select_country.explanation".podLocalized()
    self.explanationLabel = ComponentCatalog.formLabelWith(text: explanation, multiline: true,
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

extension CountrySelectorViewControllerTheme2: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cellControllers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let controller = cellControllers[indexPath.row]
    let cell = controller.cell(tableView)
    controller.isSelected = (controller === selectedController)
    return cell
  }
}

extension CountrySelectorViewControllerTheme2: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedController?.isSelected = false
    selectedController = cellControllers[indexPath.row]
    tableView.reloadData()
  }
}

private extension CountrySelectorViewControllerTheme2 {
  func setUpViewModelSubscriptions() {
    presenter.viewModel.countries.observeNext { [weak self] countries in
      guard let self = self else { return }
      self.cellControllers = countries.map { CountryCellController(country: $0, uiConfig: self.uiConfiguration) }
      self.countryList.reloadData()
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension CountrySelectorViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpBottomContainerView()
    setUpCountryList()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
  }

  func setUpTitleLabel() {
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.left.right.equalToSuperview().inset(24)
    }
  }

  func setUpExplanationLabel() {
    view.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.left.right.equalTo(titleLabel)
    }
  }

  func setUpBottomContainerView() {
    view.addSubview(bottomContainerView)
    bottomContainerView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
    }
    bottomContainerView.backgroundColor = view.backgroundColor
    setUpButton()
  }

  func setUpButton() {
    let button = ComponentCatalog.buttonWith(title: "select_card_product.select_country.call_to_action".podLocalized(),
                                             showShadow: false, uiConfig: uiConfiguration) { [weak self] in
      guard let country = self?.selectedController?.country else { return }
      self?.presenter.countrySelected(country)
    }
    bottomContainerView.addSubview(button)
    button.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(8)
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalTo(bottomConstraint).inset(16)
    }
    selectCountryButton = button
  }

  func setUpCountryList() {
    view.addSubview(countryList)
    countryList.snp.makeConstraints { make in
      make.top.equalTo(explanationLabel.snp.bottom).offset(24)
      make.bottom.equalTo(bottomContainerView.snp.top).inset(-16)
      make.left.right.equalToSuperview()
    }
    countryList.backgroundColor = view.backgroundColor
    countryList.separatorStyle = .none
    countryList.rowHeight = 48
    countryList.dataSource = self
    countryList.delegate = self
    countryList.sectionFooterHeight = 0
    selectedController = nil
  }

  func updateSelectButtonState(isEnabled: Bool) {
    selectCountryButton?.isEnabled = isEnabled
    let enabledColor = uiConfiguration.uiPrimaryColor
    let disabledColor = uiConfiguration.uiPrimaryColorDisabled
    selectCountryButton?.backgroundColor = isEnabled ? enabledColor : disabledColor
  }
}
