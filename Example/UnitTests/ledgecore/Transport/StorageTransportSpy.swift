//
//  StorageTransportSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 21/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
@testable import AptoSDK

class StorageTransportSpy: JSONTransportSpy {
    typealias TransportResult = Swift.Result<JSON, NSError>.Callback
    var requestesURLs: [URL] {
        return messages.map { $0.url }
    }
    var messages = [(url: URL, completion: TransportResult)]()
    
    override func get(_ url: URLConvertible,
                      authorization: JSONTransportAuthorization,
                      parameters: [String : AnyObject]?,
                      headers: [String : String]?,
                      acceptRedirectTo: ((String) -> Bool)?,
                      filterInvalidTokenResult: Bool,
                      callback: @escaping Swift.Result<JSON, NSError>.Callback) {
        super.get(url, authorization: authorization, parameters: parameters, headers: headers, acceptRedirectTo: acceptRedirectTo, filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)

        if let getURL = try? lastGetURL?.asURL(), let requestedURL = getURL {
            messages.append((requestedURL, callback))
        }
    }
    
    override func post(_ url: URLConvertible,
                       authorization: JSONTransportAuthorization,
                       parameters: [String : AnyObject]?,
                       filterInvalidTokenResult: Bool,
                       callback: @escaping Swift.Result<JSON, NSError>.Callback) {
        super.post(url, authorization: authorization, parameters: parameters, filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)
        
        if let postURL = try? lastPostURL?.asURL(), let requestedURL = postURL {
            messages.append((requestedURL, callback))
        }
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withResult result: JSON, at index: Int = 0) {
        messages[index].completion(.success(result))
    }
}
