//
//  UIFont.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 09/10/2017.
//
//

import UIKit

extension UIFont {
    func fontByReplacing(fontFace: String) -> UIFont {
        let newFontDescriptor = fontDescriptor.withFace(fontFace)
        return UIFont(descriptor: newFontDescriptor, size: pointSize)
    }
}
