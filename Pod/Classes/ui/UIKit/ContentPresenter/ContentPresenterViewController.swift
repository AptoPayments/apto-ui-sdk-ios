//
//  ContentPresenterViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 17/09/2018.
//
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class ContentPresenterViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: ContentPresenterPresenterProtocol
  private let contentView: ContentPresenterView

  init(uiConfiguration: UIConfig, presenter: ContentPresenterPresenterProtocol) {
    self.presenter = presenter
    self.contentView = ContentPresenterView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setupViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

// MARK: - Show content
private extension ContentPresenterViewController {
  func setupViewModelSubscriptions() {
    presenter.viewModel.content.ignoreNils().observeNext { content in
      self.set(content: content)
    }.dispose(in: disposeBag)
  }

  func set(content: Content) {
    contentView.set(content: content)
  }
}

// MARK: - Setup UI
private extension ContentPresenterViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpContentView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationSecondaryColor,
                                              tintColor: uiConfiguration.iconTertiaryColor)
    navigationController?.navigationBar.hideShadow()
    showNavCancelButton(uiConfiguration.iconTertiaryColor)
    setNeedsStatusBarAppearanceUpdate()
  }

  func setUpContentView() {
    view.addSubview(contentView)
    contentView.linkColor = uiConfiguration.textPrimaryColor
    contentView.underlineLinks = false
    contentView.delegate = self
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

extension ContentPresenterViewController: ContentPresenterViewDelegate {
  func linkTapped(url: TappedURL) {
    presenter.linkTapped(url.url)
  }
}
