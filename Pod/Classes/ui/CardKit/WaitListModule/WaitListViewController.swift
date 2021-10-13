//
//  WaitListViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 27/02/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class WaitListViewController: AptoViewController {
  private unowned let presenter: WaitListPresenterProtocol
  private let waitListView: WaitListView
  private let disposeBag = DisposeBag()

  init(uiConfiguration: UIConfig, presenter: WaitListPresenterProtocol) {
    self.presenter = presenter
    self.waitListView = WaitListView(uiConfig: uiConfiguration)
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
private extension WaitListViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel

    viewModel.asset.observeNext { [unowned self] asset in
      self.waitListView.set(asset: asset)
    }.dispose(in: disposeBag)
    viewModel.backgroundImage.observeNext { [unowned self] backgroundImage in
      self.waitListView.set(backgroundImage: backgroundImage)
    }.dispose(in: disposeBag)
    combineLatest(viewModel.backgroundColor,
                  viewModel.darkBackgroundColor).observeNext { [unowned self] backgroundColor, darkBackgroundColor in
      self.waitListView.set(backgroundColor: backgroundColor,
                            darkBackgroundColor: darkBackgroundColor)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension WaitListViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    navigationController?.isNavigationBarHidden = true
    setWaitListView()
  }

  func setWaitListView() {
    let title = "wait_list.wait_list.title".podLocalized()
    let mainDescription = "wait_list.wait_list.description.main".podLocalized()
    let secondaryDescription = "wait_list.wait_list.description.secondary".podLocalized()
    waitListView.set(title: title)
    waitListView.set(mainDescription: mainDescription)
    waitListView.set(secondaryDescription: secondaryDescription)
    view.addSubview(waitListView)
    waitListView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
