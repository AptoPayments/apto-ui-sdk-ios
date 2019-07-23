//
//  NotificationPreferencesViewControllerTheme2.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/03/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class NotificationPreferencesViewControllerTheme2: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: NotificationPreferencesPresenterProtocol
  private lazy var pushImage = UIImage.imageFromPodBundle("ico_notifications_push")?.asTemplate()
  private lazy var emailImage = UIImage.imageFromPodBundle("ico_notifications_email")?.asTemplate()
  private lazy var smsImage = UIImage.imageFromPodBundle("ico_notifications_sms")?.asTemplate()
  private let channelContainerView = UIView()
  private let channelTitleLabel: UILabel
  private let channel1ImageView = UIImageView()
  private let channel2ImageView = UIImageView()
  private let formView = MultiStepForm()

  init(uiConfiguration: UIConfig, presenter: NotificationPreferencesPresenterProtocol) {
    self.presenter = presenter
    self.channelTitleLabel = ComponentCatalog.starredSectionTitleLabelWith(text: " ", uiConfig: uiConfiguration)
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

private extension NotificationPreferencesViewControllerTheme2 {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.channel1.observeNext { [unowned self] channel1 in
      self.updateImageView(self.channel1ImageView, channel: channel1)
    }.dispose(in: disposeBag)
    viewModel.channel2.observeNext { [unowned self] channel2 in
      self.updateImageView(self.channel2ImageView, channel: channel2)
    }.dispose(in: disposeBag)
    combineLatest(viewModel.channel1, viewModel.channel2).observeNext { [unowned self] (channel1, channel2) in
      self.updateChannelTitleLabel(channel1: channel1, channel2: channel2)
    }.dispose(in: disposeBag)
    viewModel.categories.observeNext { [unowned self] categories in
      let rows: [NotificationCategoryFormRowView] = categories.map {
        let row = NotificationCategoryFormRowView(category: $0, uiConfig: self.uiConfiguration)
        row.didUpdateNotificationRow = { [unowned self] notificationRow in
          self.presenter.didUpdateNotificationRow(notificationRow)
        }
        return row
      }
      rows.first?.showTopSeparator = true
      self.formView.show(rows: rows)
    }.dispose(in: disposeBag)
  }

  func updateImageView(_ imageView: UIImageView, channel: NotificationChannel?) {
    guard let channel = channel else { imageView.image = nil; return }
    switch channel {
    case .push:
      imageView.image = pushImage
    case .email:
      imageView.image = emailImage
    case .sms:
      imageView.image = smsImage
    }
  }

  func updateChannelTitleLabel(channel1: NotificationChannel?, channel2: NotificationChannel?) {
    if channel1 == .push, let channel2 = channel2, channel2 != .push {
      // Only channel1 = push and channel2 != push supported right now
      let title = channel2 == .email
        ? "notification_preferences.send_push_email.title".podLocalized() 
        : "notification_preferences.send_push_sms.title".podLocalized()
      channelTitleLabel.updateAttributedText(title)
    }
    else {
      channelTitleLabel.updateAttributedText(" ")
    }
  }
}

// MARK: - Set up UI
private extension NotificationPreferencesViewControllerTheme2 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpTitle()
    setUpNavigationBar()
    setUpChannelContainerView()
    setUpFormView()
  }

  func setUpTitle() {
    self.title = "notification_preferences.title".podLocalized()
  }

  func setUpNavigationBar() {
    navigationItem.leftBarButtonItem?.tintColor = uiConfiguration.iconTertiaryColor
  }

  func setUpChannelContainerView() {
    channelContainerView.backgroundColor = uiConfiguration.uiNavigationSecondaryColor
    view.addSubview(channelContainerView)
    channelContainerView.snp.makeConstraints { make in
      make.height.equalTo(48)
      make.left.top.right.equalToSuperview()
    }
    setUpChannelTitleLabel()
    setUpChannel2ImageView()
    setUpChannel1ImageView()
  }

  func setUpChannelTitleLabel() {
    channelContainerView.addSubview(channelTitleLabel)
    channelTitleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(24)
    }
  }

  func setUpChannel2ImageView() {
    channel2ImageView.tintColor = uiConfiguration.iconTertiaryColor
    channel2ImageView.contentMode = .center
    channelContainerView.addSubview(channel2ImageView)
    channel2ImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().inset(28)
      make.width.height.equalTo(22)
    }
  }

  func setUpChannel1ImageView() {
    channel1ImageView.tintColor = uiConfiguration.iconTertiaryColor
    channel1ImageView.contentMode = .center
    channelContainerView.addSubview(channel1ImageView)
    channel1ImageView.snp.makeConstraints { make in
      make.centerY.equalTo(channel2ImageView)
      make.right.equalTo(channel2ImageView.snp.left).offset(-38)
      make.width.height.equalTo(channel2ImageView)
    }
  }

  func setUpFormView() {
    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.left.bottom.right.equalToSuperview()
      make.top.equalTo(channelContainerView.snp.bottom).offset(16)
    }
  }
}
