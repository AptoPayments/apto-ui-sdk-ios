//
// WebBrowserViewControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 19/11/2018.
//

import UIKit
import AptoSDK
import SnapKit
import WebKit

class WebBrowserViewControllerTheme2: WebBrowserViewControllerProtocol {
  private let webView = WKWebView()
  private unowned let presenter: WebBrowserEventHandlerProtocol
  private let alternativeTitle: String?

  init(alternativeTitle: String?, uiConfiguration: UIConfig, presenter: WebBrowserEventHandlerProtocol) {
    self.alternativeTitle = alternativeTitle
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    presenter.viewLoaded()
  }

  func load(url: URL, headers: [String: String]?) {
    self.showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
    let request = NSMutableURLRequest(url: url)
    if let headers = headers {
      request.allHTTPHeaderFields = headers
    }
    webView.load(request as URLRequest)
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

extension WebBrowserViewControllerTheme2: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.hideLoadingSpinner()
    guard let title = webView.title, !title.isEmpty else {
      self.title = alternativeTitle
      return
    }
    self.title = title
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    guard (error as NSError).code != NSURLErrorCancelled else  { return }
    hideLoadingSpinner()
    show(error: error)
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let urlString = navigationAction.request.url?.absoluteString, urlString.hasPrefix("shift-sdk://oauth-finish") {
      decisionHandler(.cancel)
      closeTapped()
    }
    else {
      decisionHandler(.allow)
    }
  }
}

private extension WebBrowserViewControllerTheme2 {
  func setUpUI() {
    setUpNavigationBar()
    setUpWebView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.textTopBarPrimaryColor)
  }

  func setUpWebView() {
    view.addSubview(webView)
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    webView.navigationDelegate = self
  }
}
