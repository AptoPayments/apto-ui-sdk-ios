//
// PaddingLabel.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 11/01/2019.
//

import Foundation

class PaddingLabel: UILabel {
  var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

  override public func drawText(in rect: CGRect) {
    let newRect: CGRect
    #if swift(>=4.2)
    newRect = rect.inset(by: padding)
    #else
    newRect = UIEdgeInsetsInsetRect(rect, padding)
    #endif
    super.drawText(in: newRect)
  }

  override public var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + padding.left + padding.right,
                  height: size.height + padding.top + padding.bottom)
  }
}
