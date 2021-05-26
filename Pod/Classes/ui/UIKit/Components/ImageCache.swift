//
//  ImageCache.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 01/04/16.
//
//

import Foundation
import AptoSDK

class ImageCache {
  static var shared = ImageCache() // swiftlint:disable:this implicitly_unwrapped_optional
  private var cache = NSCache<NSString, UIImage>()

    private init() {}
    
  func imageWithUrl(_ url: URL, result: Result<UIImage, NSError>.Callback? = nil) {
    let cachedKey = url.absoluteString as NSString
    guard let retVal = cache.object(forKey: cachedKey) else {
      let request: URLRequest = URLRequest(url: url)
        let session = URLSession.shared
      let task = session.dataTask(with: request) { [weak self] (data, _, error) -> Void in
        guard let self = self else { return }
        if error == nil {
          guard let data = data else {
            return
          }
          guard let image = UIImage(data: data) else {
            self.returnResult(callback: result, result: .failure(ServiceError(code: .internalIncosistencyError)))
            return
          }
            self.cache.setObject(image, forKey: cachedKey)
          self.returnResult(callback: result, result: .success(image))
        }
        else {
          self.returnResult(callback: result, result: .failure(ServiceError(code: .internalIncosistencyError)))
        }
      }
      task.resume()
      return
    }
    returnResult(callback: result, result: .success(retVal))
  }

  fileprivate func returnResult(callback: Result<UIImage, NSError>.Callback? = nil, result: Result<UIImage, NSError>) {
    DispatchQueue.main.async {
      callback?(result)
    }
  }
}
