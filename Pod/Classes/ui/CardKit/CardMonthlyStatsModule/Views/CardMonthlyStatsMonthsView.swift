//
//  CardMonthlyStatsMonthsView.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 07/01/2019.
//

import UIKit
import AptoSDK
import SnapKit

protocol CardMonthlyStatsMonthsViewDelegate: class {
  func leftLabelTapped(associatedDate: Date?)
  func centerLabelTapped(associatedDate: Date?)
  func rightLabelTapped(associatedDate: Date?)
}

class CardMonthlyStatsMonthsView: UIView {
  private let uiConfig: UIConfig
  private let leftLabel: UILabel
  private let centerLabel: UILabel
  private let rightLabel: UILabel
  private static let monthDateFormatter = DateFormatter.customDateFormatter(dateFormat: "MMMM")
  private var previousMonthDate: Date?
  private var currentMonthDate: Date?
  private var nextMonthDate: Date?

  var showPreviousMonth: Bool = true {
    didSet {
      leftLabel.isHidden = !showPreviousMonth
    }
  }
  var showNextMonth: Bool = true {
    didSet {
      rightLabel.isHidden = !showNextMonth
    }
  }

  var showFutureMonths = false {
    didSet {
      guard let date = currentMonthDate else { return }
      set(date: date, animated: true)
    }
  }
  weak var delegate: CardMonthlyStatsMonthsViewDelegate?

  init(uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    self.leftLabel = ComponentCatalog.timestampLabelWith(text: "", uiConfig: uiConfig)
    self.centerLabel = ComponentCatalog.sectionTitleLabelWith(text: "", textAlignment: .center, uiConfig: uiConfig)
    self.rightLabel = ComponentCatalog.timestampLabelWith(text: "", textAlignment: .right, uiConfig: uiConfig)
    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(date: Date, animated: Bool) {
    let previousDate = Calendar.current.date(byAdding: .month, value: -1, to: date)
    var nextDate = Calendar.current.date(byAdding: .month, value: 1, to: date)
    if !showFutureMonths && nextDate?.isGreaterThanDate(Date()) == true {
      nextDate = nil
    }
    updateLabel(leftLabel, with: previousDate)
    updateLabel(centerLabel, with: date)
    updateLabel(rightLabel, with: nextDate)

    if animated {
      let currentFrame = frame
      UIView.animate(withDuration: 0.4,
                     animations: { [unowned self] in
                       var offset = self.bounds.width / 3
                       if let current = self.currentMonthDate, current.isLessThanDate(date) {
                         offset *= -1
                       }
                       self.frame = self.frame.offsetBy(dx: offset, dy: 0)
                     },
                     completion: { [unowned self] _ in
                       self.frame = currentFrame
      })
    }
    currentMonthDate = date
    previousMonthDate = previousDate
    nextMonthDate = nextDate
  }

  private func updateLabel(_ label: UILabel, with date: Date?) {
    guard let date = date else {
      label.text = ""
      return
    }
    label.text = CardMonthlyStatsMonthsView.monthDateFormatter.string(from: date)
  }

  @objc func leftLabelTapped() {
    delegate?.leftLabelTapped(associatedDate: previousMonthDate)
  }

  @objc func rightLabelTapped() {
    guard let nextMonthDate = self.nextMonthDate else { return }
    delegate?.rightLabelTapped(associatedDate: nextMonthDate)
  }
}

// MARK: - Set up UI
private extension CardMonthlyStatsMonthsView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundSecondaryColor
    setUpLeftLabel()
    setUpCenterLabel()
    setUpRightLabel()
    setUpSwipeRecognizers()
  }

  func setUpLeftLabel() {
    addSubview(leftLabel)
    leftLabel.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    leftLabel.addTapGestureRecognizer { [weak self] in
      self?.leftLabelTapped()
    }
  }

  func setUpCenterLabel() {
    centerLabel.textColor = uiConfig.textPrimaryColor
    addSubview(centerLabel)
    centerLabel.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.centerX.equalToSuperview()
      make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(16)
    }
    centerLabel.addTapGestureRecognizer { [weak self] in
      self?.delegate?.centerLabelTapped(associatedDate: self?.currentMonthDate)
    }
  }

  func setUpRightLabel() {
    addSubview(rightLabel)
    rightLabel.snp.makeConstraints { make in
      make.right.equalToSuperview()
      make.centerY.equalToSuperview()
      make.left.greaterThanOrEqualTo(centerLabel.snp.right).offset(16)
    }
    rightLabel.addTapGestureRecognizer { [weak self] in
      self?.rightLabelTapped()
    }
  }

  func setUpSwipeRecognizers() {
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(leftLabelTapped))
    swipeLeft.direction = .right
    addGestureRecognizer(swipeLeft)
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(rightLabelTapped))
    swipeRight.direction = .left
    addGestureRecognizer(swipeRight)
  }
}
