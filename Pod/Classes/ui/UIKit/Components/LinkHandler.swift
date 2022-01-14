//
//  LinkHandler.swift
//  SwiftSDK
//
//  Created by Ivan Oliver Martínez on 25/08/16.
//
//

import TTTAttributedLabel
import UIKit

public protocol URLHandlerProtocol: AnyObject {
    func showExternal(url: URL, headers: [String: String]?, useSafari: Bool?, alternativeTitle: String?)
}

open class LinkHandler: NSObject, TTTAttributedLabelDelegate {
    unowned let urlHandler: URLHandlerProtocol

    public init(urlHandler: URLHandlerProtocol) {
        self.urlHandler = urlHandler
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    open func attributedLabel(_: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        urlHandler.showExternal(url: url, headers: nil, useSafari: false, alternativeTitle: nil)
    }
}
