//
// NotificationPreferencesViewControllerTheme1.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/03/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class NotificationPreferencesViewControllerTheme1: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: NotificationPreferencesPresenterProtocol

  init(uiConfiguration: UIConfig, presenter: NotificationPreferencesPresenterProtocol) {
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

  override func closeTapped() {
    presenter.closeTapped()
  }
}

private extension NotificationPreferencesViewControllerTheme1 {
  func setUpViewModelSubscriptions() {
    // TODO: listen to view model changes
  }
}

// MARK: - Set up UI
private extension NotificationPreferencesViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpTitle()
  }

  func setUpTitle() {
    self.title = "notification_preferences.title".podLocalized()
  }
}
