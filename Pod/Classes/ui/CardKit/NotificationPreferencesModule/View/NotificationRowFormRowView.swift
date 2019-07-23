//
// NotificationRowFormRowView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/05/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class NotificationRowFormRowView: UIView {
  private let disposeBag = DisposeBag()
  private let notificationRow: NotificationRow
  private let uiConfig: UIConfig
  private let titleLabel: UILabel
  private let checkboxesView: DoubleCheckbox

  var didUpdateNotificationRow: ((NotificationRow) -> Void)?

  init(notificationRow: NotificationRow, uiConfig: UIConfig) {
    self.notificationRow = notificationRow
    self.uiConfig = uiConfig
    self.titleLabel = ComponentCatalog.mainItemRegularLabelWith(text: notificationRow.title, uiConfig: uiConfig)
    self.checkboxesView = DoubleCheckbox(value1: notificationRow.isChannel1Active,
                                         value2: notificationRow.isChannel2Active, uiConfig: uiConfig)
    super.init(frame: .zero)
    setUpUI()
    setUpCheckboxesListeners()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Observe changes
private extension NotificationRowFormRowView {
  func setUpCheckboxesListeners() {
    let checkbox1 = checkboxesView.checkbox1
    let checkbox2 = checkboxesView.checkbox2
    combineLatest(checkbox1.isChecked, checkbox2.isChecked).observeNext { [unowned self] (checked1, checked2) in
      self.notificationRow.isChannel1Active = checked1
      self.notificationRow.isChannel2Active = checked2
      self.didUpdateNotificationRow?(self.notificationRow)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension NotificationRowFormRowView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundSecondaryColor
    setUpTitleLabel()
    setUpCheckboxesView()
  }

  func setUpTitleLabel() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().offset(4)
    }
  }

  func setUpCheckboxesView() {
    checkboxesView.backgroundColor = backgroundColor
    addSubview(checkboxesView)
    checkboxesView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.right.equalToSuperview().inset(10)
      make.height.equalTo(18)
    }
  }
}
