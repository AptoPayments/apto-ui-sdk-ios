//
//  ShowGenericMessageViewController.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import AptoSDK
import TTTAttributedLabel
import UIKit
import WebKit

protocol ShowGenericMessageEventHandler {
    func viewLoaded()
    func callToActionTapped()
    func secondaryCallToActionTapped()
    func closeTapped()
    func linkTapped(_ url: URL)
}

class ShowGenericMessageViewController: AptoViewController, ShowGenericMessageViewProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var eventHandler: ShowGenericMessageEventHandler
    fileprivate var logoImageView: UIImageView!
    fileprivate let webView = WKWebView()
    fileprivate var callToActionButton: UIButton!
    // swiftlint:enable implicitly_unwrapped_optional

    init(uiConfiguration: UIConfig, eventHandler: ShowGenericMessageEventHandler) {
        self.eventHandler = eventHandler
        super.init(uiConfiguration: uiConfiguration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "disclaimer.title".podLocalized()
        showNavCancelButton(uiConfiguration.iconTertiaryColor)

        webView.isHidden = true
        webView.backgroundColor = UIColor.white
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(10)
            make.left.right.equalTo(view).inset(10)
        }

        callToActionButton = UIButton.roundedButtonWith(
            "disclaimer.button.find-loan".podLocalized(),
            backgroundColor: uiConfiguration.tintColor,
            accessibilityLabel: "Find a Loan Button"
        ) { self.eventHandler.callToActionTapped() }
        view.addSubview(callToActionButton)
        callToActionButton.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(44)
            make.bottom.equalTo(view).offset(-20)
        }

        edgesForExtendedLayout = .top
        extendedLayoutIncludesOpaqueBars = true

        eventHandler.viewLoaded()
    }

    func set(title: String, logo _: String?, content: Content?, callToAction: CallToAction?) {
        self.title = title

        if let text = content?.htmlString(font: uiConfiguration.fontProvider.timestampFont,
                                          color: uiConfiguration.noteTextColor,
                                          linkColor: uiConfiguration.tintColor)
        {
            let markdownStyle =
                """
                body { font-family: '-apple-system','HelveticaNeue'; font-size:14; }
                h1 { font-size:18; }
                h2 { font-size:16; }
                """
            let htmlDoc =
                """
                <html>
                <head>
                  <style>\(markdownStyle)</style>
                </head>
                <body>
                  \(text)
                </body>
                </html>
                """
            webView.loadHTMLString(htmlDoc, baseURL: nil)
            webView.isHidden = false
        } else {
            webView.isHidden = true
        }

        if let callToAction = callToAction {
            callToActionButton.setTitle(callToAction.title, for: .normal)
            callToActionButton.isHidden = false
        } else {
            callToActionButton.isHidden = true
        }
    }

    override func closeTapped() {
        eventHandler.closeTapped()
    }
}

extension ShowGenericMessageViewController: TTTAttributedLabelDelegate {
    // swiftlint:disable:next implicitly_unwrapped_optional
    func attributedLabel(_: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        eventHandler.linkTapped(url)
    }
}
