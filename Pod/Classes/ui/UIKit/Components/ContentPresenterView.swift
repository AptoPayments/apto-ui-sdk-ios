//
// ContentPresenterView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-11-29.
//

import UIKit
import AptoSDK
import SnapKit
import TTTAttributedLabel
import WebKit

struct TappedURL {
  let title: String?
  let url: URL
}

protocol ContentPresenterViewDelegate: class {
  func linkTapped(url: TappedURL)
  func showMessage(_ message: String)
  func show(error: Error)
  func showLoadingSpinner()
  func hideLoadingSpinner()
  func didScrollToBottom()
}

extension ContentPresenterViewDelegate {
  // Make this method "Optional"
  func didScrollToBottom() {}
}

class ContentPresenterView: UIView {
  private let uiConfig: UIConfig
  private let webView = WKWebView()
  private let textView = TTTAttributedLabel(frame: CGRect.zero)
  private let waitListView: WaitListView

  weak var delegate: ContentPresenterViewDelegate?

  /// Text alignment for plainText and markdown. For html content this value is ignored.
  var textAlignment: NSTextAlignment {
    get {
      return textView.textAlignment
    }
    set {
      textView.textAlignment = newValue
    }
  }

  /// Only applies for plainText and markdown. For html content this value is ignored.
  var lineSpacing: CGFloat = 0

  /// Only applies for plainText and markdown. For html content this value is ignored.
  var font: UIFont

  /// Only applies for plainText and markdown. For html content this value is ignored.
  var textColor: UIColor
  var linkColor: UIColor {
    didSet {
      updateLinkAttributes()
    }
  }
  var underlineLinks: Bool = false {
    didSet {
      updateLinkAttributes()
    }
  }

  init(uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    self.font = uiConfig.fontProvider.instructionsFont
    self.textColor = uiConfig.textPrimaryColor
    self.linkColor = uiConfig.uiPrimaryColor
    self.waitListView = WaitListView(uiConfig: uiConfig, isAssetOptional: true)
    super.init(frame: .zero)

    setUpUI()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(content: Content) {
    switch content {
    case .plainText, .markdown:
      guard let attributedString = content.attributedString(font: font,
                                                            color: textColor,
                                                            linkColor: linkColor,
                                                            lineSpacing: lineSpacing) else {
        showEmptyDisclaimer()
        return
      }
      show(attributedString)
    case .externalURL(let url):
      show(url)
    case .nativeContent(let nativeContent):
      show(nativeContent)
    }
  }

  func set(title: String) {
    waitListView.set(title: title)
  }

  func set(mainDescription: String) {
    waitListView.set(mainDescription: mainDescription)
  }

  func set(secondaryDescription: String) {
    waitListView.set(secondaryDescription: secondaryDescription)
  }
}

private extension ContentPresenterView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundPrimaryColor
    setUpWebView()
    setUpTextView()
    setUpWaitListView()
  }

  func setUpTextView() {
    addSubview(textView)
    updateLinkAttributes()
    textView.enabledTextCheckingTypes = NSTextCheckingAllTypes
    textView.delegate = self
    textView.numberOfLines = 0
    textView.verticalAlignment = .top
    textView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(uiConfig.formRowPadding.left)
      make.top.equalToSuperview().offset(26)
      make.bottom.equalToSuperview()
    }
    textView.isHidden = true
  }

  func updateLinkAttributes() {
    textView.linkAttributes = [NSAttributedString.Key.foregroundColor: linkColor,
                               kCTUnderlineStyleAttributeName as AnyHashable: underlineLinks]
  }

  func setUpWebView() {
    webView.isHidden = true
    addSubview(webView)
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    webView.navigationDelegate = self
    webView.scrollView.delegate = self
  }

  func setUpWaitListView() {
    waitListView.isHidden = true
    addSubview(waitListView)
    waitListView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func show(_ attributedString: NSAttributedString) {
    textView.setText(attributedString)
    webView.isHidden = true
    waitListView.isHidden = true
    textView.isHidden = false
  }

  func show(_ url: URL) {
    delegate?.showLoadingSpinner()
    let request = NSMutableURLRequest(url: url)
    webView.load(request as URLRequest)
    webView.isHidden = false
    waitListView.isHidden = true
    textView.isHidden = true
  }

  func show(_ nativeContent: NativeContent) {
    waitListView.set(backgroundImage: nativeContent.backgroundImage)
    waitListView.set(asset: nativeContent.asset)
    waitListView.set(backgroundColor: nativeContent.backgroundColor)
    webView.isHidden = true
    waitListView.isHidden = false
    textView.isHidden = true
  }

  func showEmptyDisclaimer() {
    delegate?.showMessage("Sorry, the content can't be shown at this moment. Please try again later.")
  }
}

extension ContentPresenterView: TTTAttributedLabelDelegate {
  //swiftlint:disable:next implicitly_unwrapped_optional
  func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    var title: String?
    label.attributedText.enumerateAttribute(NSAttributedString.Key.link,
                                            in: NSRange(location: 0, length: label.attributedText.length),
                                            options: .longestEffectiveRangeNotRequired) { (attribute, range, _) in
      guard let tappedURL = attribute as? URL else {
        return
      }
      if tappedURL == url {
        title = label.attributedText.attributedSubstring(from: range).string
      }
    }
    delegate?.linkTapped(url: TappedURL(title: title, url: url))
  }
}

extension ContentPresenterView: WKNavigationDelegate {
  // swiftlint:disable:next implicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    guard (error as NSError).code != NSURLErrorCancelled else  { return }
    delegate?.hideLoadingSpinner()
    delegate?.show(error: error)
  }

  // swiftlint:disable:next implicitly_unwrapped_optional
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    delegate?.hideLoadingSpinner()
    // Wait for a second before verifying if the content loaded fit in the screen or not.
    // This has a double objective: 1) fix a case where for some URLs the content is not rendered
    // and the delegate method is called when it shouldn't. 2) make the user to wait at least for
    // a second before being able to tap the Continue button.
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self, unowned webView] in
      if webView.scrollView.contentOffset.y >=
          (webView.scrollView.contentSize.height - webView.scrollView.frame.size.height) {
        // Scroll to bottom
        self?.delegate?.didScrollToBottom()
      }
    }
  }
}

extension ContentPresenterView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentSize.height > scrollView.frame.size.height {
      if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
        // Scroll to bottom
        delegate?.didScrollToBottom()
      }
    }
  }
}
