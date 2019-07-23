//
//  WebBrowserViewControllerTheme1.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/08/16.
//
//

import UIKit
import AptoSDK

class WebBrowserViewControllerTheme1: WebBrowserViewControllerProtocol {
  private let webView = UIWebView()
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
    webView.delegate = self
  }

  // MARK: WebBrowserViewProtocol

  func load(url:URL, headers:[String:String]?) {
    self.showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor)
    let request = NSMutableURLRequest(url: url)
    if let headers = headers {
      request.allHTTPHeaderFields = headers
    }
    webView.loadRequest(request as URLRequest)
  }

  // MARK: Private

  override func closeTapped() {
    eventHandler.closeTapped()
  }
}

extension WebBrowserViewControllerTheme1: UIWebViewDelegate {
  func webViewDidFinishLoad(_ aWebView: UIWebView) {
    self.hideLoadingSpinner()
    guard let title = aWebView.stringByEvaluatingJavaScript(from: "document.title"), !title.isEmpty else {
      self.title = alternativeTitle
      return
    }
    self.title = title
  }

  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    guard (error as NSError).code != -999 else  {
      return
    }
    self.hideLoadingSpinner()
    self.show(error: error)
  }

  func webView(_ webView: UIWebView,
               shouldStartLoadWith request: URLRequest,
               navigationType: UIWebView.NavigationType) -> Bool {
    if let urlString = request.url?.absoluteString, urlString.hasPrefix("shift-sdk://oauth-finish") {
      defer { closeTapped() }
      return false
    }

    return true
  }
}
