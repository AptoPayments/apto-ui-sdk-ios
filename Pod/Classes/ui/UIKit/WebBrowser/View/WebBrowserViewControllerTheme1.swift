//
//  WebBrowserViewControllerTheme1.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/08/16.
//
//

import UIKit
import AptoSDK
import WebKit

class WebBrowserViewControllerTheme1: WebBrowserViewControllerProtocol {
  private let webView = WKWebView()
  private unowned let eventHandler: WebBrowserEventHandlerProtocol
  private let alternativeTitle: String?

  init(alternativeTitle: String?, uiConfiguration: UIConfig, eventHandler: WebBrowserEventHandlerProtocol) {
    self.alternativeTitle = alternativeTitle
    self.eventHandler = eventHandler
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    eventHandler.viewLoaded()
  }

  private func setUpUI() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    self.view.addSubview(webView)
    webView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(self.view)
    }
    webView.navigationDelegate = self
  }

  // MARK: WebBrowserViewProtocol

  func load(url: URL, headers: [String: String]?) {
    self.showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
    let request = NSMutableURLRequest(url: url)
    if let headers = headers {
      request.allHTTPHeaderFields = headers
    }
    webView.load(request as URLRequest)
  }

  // MARK: Private

  override func closeTapped() {
    eventHandler.closeTapped()
  }
}

extension WebBrowserViewControllerTheme1: WKNavigationDelegate {
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
