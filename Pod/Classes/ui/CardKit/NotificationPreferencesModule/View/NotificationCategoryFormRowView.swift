//
// NotificationCategoryFormRowView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/05/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class NotificationCategoryFormRowView: FormRowView {
  private let disposeBag = DisposeBag()
  private let category: NotificationCategory
  private let topSeparatorView = UIView()
  private let uiConfig: UIConfig
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private let checkboxesView: DoubleCheckbox

  var showTopSeparator: Bool {
    didSet {
      topSeparatorView.isHidden = !showTopSeparator
    }
  }
  var didUpdateNotificationRow: ((NotificationRow) -> Void)?

  init(category: NotificationCategory, showTopSeparator: Bool = false, uiConfig: UIConfig) {
    self.category = category
    self.showTopSeparator = showTopSeparator
    self.uiConfig = uiConfig
    self.titleLabel = ComponentCatalog.sectionTitleLabelWith(text: category.title, uiConfig: uiConfig)
    self.explanationLabel = ComponentCatalog.timestampLabelWith(text: category.description, multiline: true,
                                                                uiConfig: uiConfig)
    self.checkboxesView = DoubleCheckbox(value1: category.rows[0].isChannel1Active,
                                         value2: category.rows[0].isChannel2Active, uiConfig: uiConfig)
    super.init(showSplitter: true, padding: uiConfig.formRowPadding, height: 78)
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Observe changes
private extension NotificationCategoryFormRowView {
  func setUpCheckboxesListeners() {
    let checkbox1 = checkboxesView.checkbox1
    let checkbox2 = checkboxesView.checkbox2
    combineLatest(checkbox1.isChecked, checkbox2.isChecked).observeNext { [unowned self] (checked1, checked2) in
      let row = self.category.rows[0]
      row.isChannel1Active = checked1
      row.isChannel2Active = checked2
      self.didUpdateNotificationRow?(row)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension NotificationCategoryFormRowView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundSecondaryColor
    setUpTopSeparatorView()
    setUpTitleLabel()
    setUpCheckboxesView()
    setUpExplanationLabel()
    setUpRows()
  }

  func setUpTopSeparatorView() {
    topSeparatorView.isHidden = !showTopSeparator
    topSeparatorView.backgroundColor = uiConfig.uiTertiaryColor
    contentView.addSubview(topSeparatorView)
    topSeparatorView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.height.equalTo(1)
    }
  }

  func setUpTitleLabel() {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.left.equalToSuperview().offset(4)
    }
  }

  func setUpCheckboxesView() {
    checkboxesView.isHidden = true
    checkboxesView.backgroundColor = backgroundColor
    contentView.addSubview(checkboxesView)
    checkboxesView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.right.equalToSuperview().inset(10)
    }
  }

  func setUpExplanationLabel() {
    contentView.addSubview(explanationLabel)
    explanationLabel.snp.makeConstraints { make in
      make.left.equalTo(titleLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(6)
      make.right.equalTo(checkboxesView.snp.left).offset(-24)
    }
  }

  func setUpRows() {
    if category.rows.count == 1 {
      showCheckboxes()
    }
    else {
      removeCheckboxesAndUpdateExplanation()
      setUpNotificationRows()
    }
  }

  func showCheckboxes() {
    checkboxesView.isHidden = false
    checkboxesView.isEnabled = category.rows[0].isEnabled
    setUpCheckboxesListeners()
  }

  func removeCheckboxesAndUpdateExplanation() {
    checkboxesView.removeFromSuperview()
    explanationLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(10)
    }
  }

  func setUpNotificationRows() {
    let container = UIView()
    contentView.addSubview(container)
    container.backgroundColor = backgroundColor
    container.snp.makeConstraints { make in
      make.top.equalTo(explanationLabel.snp.bottom).offset(12)
      make.left.bottom.right.equalToSuperview()
    }
    var topConstraint = container.snp.top
    var lastRow: NotificationRowFormRowView?
    category.rows.forEach {
      let row = NotificationRowFormRowView(notificationRow: $0, uiConfig: uiConfig)
      row.didUpdateNotificationRow = { [unowned self] notificationRow in
        self.didUpdateNotificationRow?(notificationRow)
      }
      container.addSubview(row)
      row.snp.makeConstraints { make in
        make.top.equalTo(topConstraint).offset(16)
        make.left.right.equalToSuperview()
        make.height.equalTo(46)
      }
      lastRow = row
      topConstraint = row.snp.bottom
    }
    lastRow?.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
    }
  }
}
