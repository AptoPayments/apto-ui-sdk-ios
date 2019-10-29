//
//  MonthlyStatementListCell.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 02/10/2019.
//

import UIKit
import AptoSDK
import SnapKit

class MonthlyStatementListCell: UITableViewCell {
  private let label = UILabel()
  private let bottomDividerView = UIView()
  private var styleInitialized = false
  private var uiConfig: UIConfig! // swiftlint:disable:this implicitly_unwrapped_optional
  private static let dateFormatter = DateFormatter.customLocalizedDateFormatter(dateFormat: "MMMM")

  var shouldDrawBottomDivider: Bool = false {
    didSet {
      bottomDividerView.isHidden = !shouldDrawBottomDivider
    }
  }

  weak var cellController: MonthlyStatementListCellController?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    self.accessoryType = .disclosureIndicator
    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setUIConfig(_ uiConfiguration: UIConfig) {
    guard !self.styleInitialized else { return }
    uiConfig = uiConfiguration
    backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    contentView.backgroundColor = backgroundColor
    backgroundView?.backgroundColor = backgroundColor
    label.font = uiConfiguration.fontProvider.mainItemRegularFont
    label.textColor = uiConfiguration.textPrimaryColor
    bottomDividerView.backgroundColor = uiConfiguration.uiTertiaryColor
    accessoryView?.tintColor = uiConfiguration.uiTertiaryColor
    styleInitialized = true
  }

  func set(month: Month) {
    guard let date = month.toDate() else {
      label.text = ""
      return
    }
    label.text = MonthlyStatementListCell.dateFormatter.string(from: date)
  }
}

private extension MonthlyStatementListCell {
  func setUpUI() {
    setUpLabel()
    setUpBottomDivider()
    setUpAccessoryView()
  }

  func setUpLabel() {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(36)
    }
  }

  func setUpBottomDivider() {
    contentView.addSubview(bottomDividerView)
    bottomDividerView.snp.makeConstraints { make in
      make.height.equalTo(1)
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }

  func setUpAccessoryView() {
    accessoryView = UIImageView(image: UIImage.imageFromPodBundle("row_arrow")?.asTemplate())
  }
}
