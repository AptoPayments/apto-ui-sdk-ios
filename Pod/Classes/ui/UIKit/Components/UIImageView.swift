//
//  UIImageView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 01/04/16.
//
//

import Foundation

private var imageUrlAssociationKey: UInt8 = 0

public extension UIImageView {
    var imageUrl: URL? {
        get {
            return objc_getAssociatedObject(self, &imageUrlAssociationKey) as? URL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &imageUrlAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    func setImageUrl(_ url: URL, result: Result<Void, NSError>.Callback? = nil) {
        imageUrl = url
        ImageCache.shared.imageWithUrl(url) { [weak self] response in
            if self?.imageUrl != url {
                return
            }
            switch response {
            case let .failure(error):
                result?(.failure(error))
            case let .success(image):
                DispatchQueue.main.async {
                    self?.contentMode = .scaleAspectFit
                    self?.image = image
                    result?(Result.success(()))
                }
            }
        }
    }
}
