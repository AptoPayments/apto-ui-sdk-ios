//
//  MonthlyStatementsReportViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/09/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit
import WebKit

class MonthlyStatementsReportViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: MonthlyStatementsReportPresenterProtocol
  private var url: URL?
  private let webView = WKWebView(frame: .zero)
  private lazy var shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

  init(uiConfiguration: UIConfig, presenter: MonthlyStatementsReportPresenterProtocol) {
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

  @objc private func shareTapped() {
    guard let url = self.url else { return }
    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    present(activityViewController, animated: true)
  }
}

extension MonthlyStatementsReportViewController: WKNavigationDelegate {
  // swiftlint:disable:next implicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    hideLoadingSpinner()
    shareButton.isEnabled = true
  }
}

private extension MonthlyStatementsReportViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    combineLatest(viewModel.month, viewModel.year).observeNext { [weak self] month, year in
      self?.updateTitle(month: month, year: year)
    }.dispose(in: disposeBag)
    viewModel.url.ignoreNils().observeNext { [weak self] url in
      self?.show(url: url)
      }.dispose(in: disposeBag)
    viewModel.error.ignoreNils().observeNext { [weak self] error in
      self?.show(error: error)
    }.dispose(in: disposeBag)
  }

  func updateTitle(month: String, year: String) {
    self.title = "monthly_statements.report.title".podLocalized().replace([
      "<<MONTH>>": month,
      "<<YEAR>>": year
    ])
  }

  func show(url: URL) {
    showLoadingSpinner()
    self.url = url
    webView.load(URLRequest(url: url))
  }
}

// MARK: - Set up UI
private extension MonthlyStatementsReportViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
    setUpNavigationBar()
    setUpShareButton()
    setUpWebView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationSecondaryColor,
                                              tintColor: uiConfiguration.textTopBarSecondaryColor)
    navigationItem.leftBarButtonItem?.tintColor = uiConfiguration.textTopBarSecondaryColor
  }

  func setUpShareButton() {
    shareButton.isEnabled = false
    navigationItem.rightBarButtonItem = shareButton
  }

  func setUpWebView() {
    webView.navigationDelegate = self
    view.addSubview(webView)
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
